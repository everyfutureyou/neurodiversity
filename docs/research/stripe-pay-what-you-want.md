# Stripe Pay-What-You-Want — Research Findings

**Issue:** [#4 — Research: Stripe pay-what-you-want implementation patterns](https://github.com/everyfutureyou/neurodiversity/issues/4)  
**Date:** 2026-08-04  
**Sources:** Stripe official documentation (docs.stripe.com)

---

## Summary

Stripe supports pay-what-you-want (PWYW) pricing, but **not through a single unified feature**. The built-in `custom_unit_amount` Price parameter works only for one-time payments in Checkout — it explicitly does **not** support recurring subscriptions. For a recurring membership at a user-chosen amount (including €0), a hybrid approach is required: a free subscription track for €0 members and a dynamic-price subscription track for paying members.

---

## 1. `custom_unit_amount` — Stripe's Built-In PWYW Feature

Stripe provides `custom_unit_amount` on the [Price object](https://docs.stripe.com/api/prices/create) to let customers name their price in a Checkout Session.

```bash
# Create a PWYW price
curl https://api.stripe.com/v1/prices \
  -u "sk_..." \
  -d currency=eur \
  -d "custom_unit_amount[enabled]=true" \
  -d "custom_unit_amount[minimum]=100" \   # €1.00 minimum (optional)
  -d "custom_unit_amount[preset]=500" \   # €5.00 suggested default (optional)
  -d "product={{PRODUCT_ID}}"
```

Parameters ([source](https://docs.stripe.com/api/prices/create#create_price-custom_unit_amount)):

| Parameter | Purpose |
|---|---|
| `custom_unit_amount[enabled]` | Must be `true` to activate |
| `custom_unit_amount[minimum]` | Minimum in smallest currency unit (e.g. cents); must be ≥ Stripe's minimum charge |
| `custom_unit_amount[maximum]` | Optional cap |
| `custom_unit_amount[preset]` | Pre-filled suggested amount |

**Critical limitation:** Recurring payments are explicitly not supported with `custom_unit_amount`. From the [Checkout PWYW docs](https://docs.stripe.com/payments/checkout/pay-what-you-want):

> "Wiederkehrende Zahlungen oder optionale Posten werden nicht unterstützt."  
> *(Recurring payments or optional items are not supported.)*

Additional constraints:
- No other line items may be added alongside a PWYW price
- Quantity is locked to 1
- Promo codes and discounts cannot be applied

---

## 2. Recurring Custom-Amount Subscriptions

Since `custom_unit_amount` is limited to one-time payments, a **dynamic Price creation pattern** is needed for recurring PWYW subscriptions:

1. Collect the desired monthly amount from the user in your own UI (custom form/slider)
2. Server-side: create a `Price` object with `unit_amount` set to the user's chosen amount and `recurring[interval]=month`
3. Create a Checkout Session in `subscription` mode (or call the Subscriptions API directly) with that Price ID

```bash
# Step 1: Create a dynamic recurring price for the chosen amount
curl https://api.stripe.com/v1/prices \
  -u "sk_..." \
  -d currency=eur \
  -d unit_amount=1000 \          # customer chose €10/month
  -d "recurring[interval]=month" \
  -d "product={{PRODUCT_ID}}"

# Step 2: Create a Checkout Session (subscription mode)
curl https://api.stripe.com/v1/checkout/sessions \
  -u "sk_..." \
  -d "line_items[0][price]={{NEW_PRICE_ID}}" \
  -d "line_items[0][quantity]=1" \
  -d mode=subscription \
  -d customer={{CUSTOMER_ID}} \
  --data-urlencode "success_url=https://example.com/success"
```

Sources: [Prices API](https://docs.stripe.com/api/prices/create), [Build a Subscription](https://docs.stripe.com/billing/subscriptions/build-subscriptions)

**Note on Stripe EUR minimum charge:** Stripe requires a minimum charge of €0.50 for EUR. Any custom subscription amount must be either €0 (free track) or ≥ €0.50. The UI should enforce this.

---

## 3. Membership Activation at €0 — No Stripe Transaction

When the chosen amount is zero, no Stripe payment transaction occurs. Stripe fully supports `unit_amount=0` on a Price object ([source](https://docs.stripe.com/api/prices/create#create_price-unit_amount)):

> "A positive integer in the smallest currency unit **(or 0 for a free price)** representing how much to charge."

**Free (€0) subscription behaviour:**
- Create a Stripe Customer (to store the email and enable future upgrades)
- Create a recurring Price with `unit_amount=0`
- Create a Subscription — Stripe immediately generates a zero-amount invoice, auto-marks it as `paid`, and sets the subscription `status` to `active`
- **No payment method is required** — no redirect to Checkout
- The membership is active immediately

```bash
# Create a €0/month price (reusable)
curl https://api.stripe.com/v1/prices \
  -u "sk_..." \
  -d currency=eur \
  -d unit_amount=0 \
  -d "recurring[interval]=month" \
  -d "product={{MEMBERSHIP_PRODUCT_ID}}"

# Create the free subscription directly (no Checkout Session needed)
curl https://api.stripe.com/v1/subscriptions \
  -u "sk_..." \
  -d customer={{CUSTOMER_ID}} \
  -d "items[0][price]={{FREE_PRICE_ID}}"
  # subscription.status will immediately be "active"
```

Source: [Subscription overview — how subscriptions work](https://docs.stripe.com/billing/subscriptions/overview)

**Access grant logic for €0:** Because the subscription is immediately `active`, the app can grant access right after the Subscription create API call returns, or reliably via the `customer.subscription.created` webhook (the subscription will already have `status: active`).

---

## 4. Recommended Hybrid Architecture

```
Registration
    │
    ├─ User chooses €0
    │      └─ Server creates Stripe Customer + Subscription (€0 price)
    │           └─ subscription.status = "active" immediately → grant access
    │
    └─ User chooses > €0 (e.g. €5, €10, custom)
           └─ Server creates Stripe Customer + dynamic recurring Price
                └─ Redirect to Stripe Checkout (subscription mode)
                     └─ On checkout.session.completed → subscription created
                          └─ On invoice.paid → grant / confirm access
```

This avoids needing to touch Stripe for €0 memberships while still capturing payment methods and creating auditable Stripe subscriptions for paying members — both use the same Stripe `Customer` object and the same `Subscription` lifecycle.

---

## 5. Webhook Events to Handle

Source: [Subscription webhooks](https://docs.stripe.com/billing/subscriptions/webhooks)

### Core events

| Event | When to act |
|---|---|
| `customer.subscription.created` | Subscription provisioned. For €0 subscriptions, `status` is already `active` — grant access here. For paid subscriptions, wait for `invoice.paid`. |
| `customer.subscription.updated` | Plan changed, amount changed, status changed (e.g. `trialing` → `active`, `active` → `past_due`). Re-evaluate access. |
| `customer.subscription.deleted` | Subscription cancelled — revoke access. |
| `invoice.paid` | Payment succeeded. For paid subscriptions, this is the canonical signal to grant/extend access. |
| `invoice.payment_failed` | Payment failed. Notify user; Stripe will retry via Smart Retries. |
| `invoice.payment_action_required` | 3DS authentication needed. Notify user to complete authentication. |
| `invoice.finalization_failed` | Invoice could not be finalized (e.g. Stripe Tax location required). Handle and notify. |
| `customer.subscription.trial_will_end` | 3 days before trial ends. Prompt user to add payment method if none on file. |

### Access control events (modern approach)

| Event | When to act |
|---|---|
| `entitlements.active_entitlement_summary.updated` | Fires on every subscription state change. Contains the full current feature list. Use to drive feature flags directly. |

### Subscription status lifecycle

| Status | Meaning for access |
|---|---|
| `active` | Full access |
| `trialing` | Full access (if you offer trials) |
| `incomplete` | Payment pending (23-hour window) — withhold or allow provisional access |
| `incomplete_expired` | First payment never completed — no access |
| `past_due` | Renewal payment failed but retrying — decide per policy (warn, partial access, or revoke) |
| `canceled` | Cancelled — revoke access |
| `unpaid` | All retries exhausted — revoke access |
| `paused` | Trial ended without payment method — revoke access until resumed |

---

## 6. Stripe Entitlements — Simplifying Access Control

[Stripe Billing Entitlements](https://docs.stripe.com/billing/entitlements) is a GA feature that maps your application features to Stripe Products. When a subscription becomes active, Stripe tracks which features the customer has access to.

**Setup:**
1. Create `Feature` objects in Stripe with `lookup_key` values matching your app's feature flags (e.g. `member-content-access`)
2. Attach features to the Membership product
3. Listen for `entitlements.active_entitlement_summary.updated` webhook — the payload contains the full, current list of the customer's active features
4. Query anytime via `GET /v1/entitlements/active_entitlements?customer={id}`

**Benefit for PWYW:** The same entitlement fires whether the subscription is €0 or €50/month — your access control code doesn't need to branch on price.

---

## 7. Stripe Customer Portal

The [Customer Portal](https://docs.stripe.com/billing/subscriptions/customer-portal) is a hosted Stripe UI for self-service subscription management. It supports:
- Updating payment method
- Cancelling subscription
- Switching plan (up to 10 product choices, configurable)
- Viewing invoice history

**PWYW limitation:** The portal's plan-switching feature works with a fixed list of pre-defined prices (up to 10). It cannot present an arbitrary numeric input. To let users change their monthly contribution amount, a custom "change amount" page in the Rails app is required — it creates a new dynamic Price and calls the [Subscriptions update API](https://docs.stripe.com/billing/subscriptions/change) to swap the price.

The portal remains useful for: updating payment method, cancellation, and invoice history.

Languages: Supports German (`de`) and English (`en`) natively — auto-detected from browser. Relevant for the DE/EN i18n requirement.

---

## 8. Integration Pattern for Amount Changes

When a member wants to change their monthly contribution (e.g. from €5 to €15):

```bash
# 1. Create a new dynamic price
curl https://api.stripe.com/v1/prices \
  -u "sk_..." \
  -d currency=eur \
  -d unit_amount=1500 \
  -d "recurring[interval]=month" \
  -d "product={{MEMBERSHIP_PRODUCT_ID}}"

# 2. Update the existing subscription to the new price
curl https://api.stripe.com/v1/subscriptions/{{SUBSCRIPTION_ID}} \
  -u "sk_..." \
  -d "items[0][id]={{CURRENT_ITEM_ID}}" \
  -d "items[0][price]={{NEW_PRICE_ID}}" \
  -d proration_behavior=create_prorations
```

For a member upgrading from €0 to a paid amount, this requires adding a payment method first (via a Checkout Session in `setup` mode, or via the Customer Portal's payment method update flow).

---

## 9. Open Questions / Decisions for Later

- **Minimum amount enforcement in UI:** The UI should prevent values between €0.01 and €0.49 (below Stripe's €0.50 minimum) — either snap to €0 or €0.50+.
- **Free-to-paid upgrade UX:** When a €0 member decides to start contributing, they need to add a payment method. Rails could redirect them to a Stripe Checkout Session in `setup` mode or use the Customer Portal.
- **Price object cleanup:** Dynamic per-user prices accumulate in Stripe. They should be `active=false` after creation (lookup-key-free) or a dedicated product for each contribution tier should be used. Alternatively, set `active=false` via the API after attaching to the subscription.
- **Proration handling:** When a member changes their amount mid-cycle, decide whether to prorate immediately or at next renewal.

---

## References

- [Stripe Checkout: Pay What You Want](https://docs.stripe.com/payments/checkout/pay-what-you-want)
- [Create a Price — `custom_unit_amount`](https://docs.stripe.com/api/prices/create#create_price-custom_unit_amount)
- [Subscription Webhooks](https://docs.stripe.com/billing/subscriptions/webhooks)
- [How Subscriptions Work](https://docs.stripe.com/billing/subscriptions/overview)
- [Free Trials Without Payment Method](https://docs.stripe.com/billing/subscriptions/trials/free-trials)
- [Billing Entitlements](https://docs.stripe.com/billing/entitlements)
- [Customer Portal](https://docs.stripe.com/billing/subscriptions/customer-portal)
- [Configure the Customer Portal](https://docs.stripe.com/customer-management/configure-portal)
- [Edit Subscriptions](https://docs.stripe.com/billing/subscriptions/change)
