# frozen_string_literal: true

# Wraps Stripe API calls for the PWYW membership flow.
class StripeService
  MEMBERSHIP_PRODUCT_ID = Rails.application.credentials.dig(:stripe, :membership_product_id)

  def initialize(user)
    @user = user
  end

  # Ensures the user has a Stripe Customer and returns its ID.
  def find_or_create_customer
    if @user.stripe_customer_id.present?
      @user.stripe_customer_id
    else
      customer = Stripe::Customer.create(email: @user.email_address)
      @user.update!(stripe_customer_id: customer.id)
      customer.id
    end
  end

  # Creates a free (€0/month) subscription directly — no Checkout redirect.
  def create_free_subscription(customer_id)
    price = Stripe::Price.create(
      currency: "eur",
      unit_amount: 0,
      recurring: { interval: "month" },
      product: MEMBERSHIP_PRODUCT_ID
    )
    Stripe::Subscription.create(
      customer: customer_id,
      items: [ { price: price.id } ]
    )
  rescue Stripe::StripeError => e
    Rails.logger.error("[StripeService] create_free_subscription failed: #{e.message}")
    raise
  end

  # Creates a Stripe Checkout session for a paid subscription.
  # Returns the session URL for redirect.
  def create_checkout_session(customer_id, amount_cents:, success_url:, cancel_url:)
    price = Stripe::Price.create(
      currency: "eur",
      unit_amount: amount_cents,
      recurring: { interval: "month" },
      product: MEMBERSHIP_PRODUCT_ID
    )
    session = Stripe::Checkout::Session.create(
      customer: customer_id,
      mode: "subscription",
      line_items: [ { price: price.id, quantity: 1 } ],
      success_url: success_url,
      cancel_url: cancel_url
    )
    session.url
  rescue Stripe::StripeError => e
    Rails.logger.error("[StripeService] create_checkout_session failed: #{e.message}")
    raise
  end
end
