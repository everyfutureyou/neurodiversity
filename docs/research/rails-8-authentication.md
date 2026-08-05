# Rails 8 Built-in Authentication: Research Findings

**Issue:** [#2 — Research: Rails 8 built-in authentication capabilities](https://github.com/everyfutureyou/neurodiversity/issues/2)  
**Date:** 2026-08-04  
**Sources:** Rails 8 security guide, Rails source code, Devise README, authentication-zero README

---

## 1. What the Generator Provides

Run with `bin/rails generate authentication`. Source: [authentication_generator.rb on GitHub](https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/authentication/authentication_generator.rb).

### Files Generated

| File | Purpose |
|---|---|
| `app/models/user.rb` | User with `has_secure_password` and `normalizes :email_address` |
| `app/models/session.rb` | Session record (belongs_to user, stores ip_address and user_agent) |
| `app/models/current.rb` | Thread-local `Current.session` / `Current.user` via `CurrentAttributes` |
| `app/controllers/sessions_controller.rb` | Sign-in and sign-out |
| `app/controllers/passwords_controller.rb` | Password reset flow |
| `app/controllers/concerns/authentication.rb` | Concern included into `ApplicationController` |
| `app/mailers/passwords_mailer.rb` | Password-reset email |
| `app/views/passwords_mailer/reset.{html,text}.erb` | Mailer views |
| `app/views/sessions/new.html.erb` | Sign-in form |
| `app/views/passwords/new.html.erb` + `edit.html.erb` | Forgot-password + set-new-password forms |
| Two migrations | `CreateUsers`, `CreateSessions` |

Source: [Rails Security Guide — Authentication section](https://guides.rubyonrails.org/security.html#authentication).

### What the Authentication Concern Does

The generated concern ([source](https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/authentication/templates/app/controllers/concerns/authentication.rb.tt)):

- `before_action :require_authentication` on every controller action by default.
- `allow_unauthenticated_access` class method to opt out per controller/action.
- Sessions stored **server-side** in the `sessions` table; the cookie holds only a signed session ID (`cookies.signed.permanent[:session_id]`, `httponly: true`, `same_site: :lax`).
- `terminate_session` destroys the `Session` record server-side *and* deletes the cookie — invalidation is immediate.
- `authenticated?` helper method available in views.

### Password Reset

- `PasswordsController` sends a reset email; token is valid for **15 minutes** by default (configurable via `has_secure_password`).
- Token is generated using `generates_token_for` (Rails 7.1+), which encodes expiry into the token itself.
- Source: [Rails Security Guide — Reset Password](https://guides.rubyonrails.org/security.html#reset-password).

### Security Primitives Used

| Primitive | What it does |
|---|---|
| `has_secure_password` | Stores bcrypt hash; validates presence and max 72-byte length. |
| `authenticate_by` | Timing-safe credential lookup — prevents user-enumeration via timing. |
| `generates_token_for` | Tamper-proof, expiry-bound tokens for password reset. |
| `cookies.signed.permanent` | HMAC-signed cookie; unreadable/unmodifiable by client. |
| `httponly: true` cookie flag | Blocks JavaScript access, mitigates XSS session theft. |
| `same_site: :lax` cookie flag | Mitigates CSRF for most cross-origin flows. |

---

## 2. What Is Missing for a Production-Grade Flow

### 2.1 Registration / Sign-Up

**Not generated.** The guide is explicit:

> "After running the Authentication generator, you do need to implement your own sign up flow and add the necessary views, routes, and controller actions."

Source: [Rails Security Guide](https://guides.rubyonrails.org/security.html#authentication).

You must build a `RegistrationsController`, the form, and the `User.create` call.

### 2.2 Email Confirmation

**Not included.** There is no mechanism to verify that a user controls the email address they registered with. A production application handling access control (e.g. content behind a membership) needs this to prevent account squatting and abuse.

**How to add it without Devise:** Use `generates_token_for :email_confirmation, expires_in: 2.days` on the `User` model, send a confirmation link, and gate login behind a `confirmed_at` check.

### 2.3 "Remember Me" Toggle

The generator **always** uses `cookies.signed.permanent` — every session persists across browser restarts indefinitely (until explicitly signed out). There is no built-in "remember me / stay signed in" toggle; the session *is* always persistent. To add a session-only-cookie path, you'd modify `start_new_session_for` to branch on a form param.

### 2.4 Account Lockout After Failed Attempts

**Not included.** No `failed_attempts` counter, no lock-until-time-expires, no unlock-via-email.

**What Rails 8 does provide instead:** The built-in `rate_limit` controller method (new in Rails 7.2 / 8):

```ruby
class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create
end
```

This throttles by IP (or a custom key) and raises `429 Too Many Requests`. Source: [ActionController::RateLimiting API](https://edgeapi.rubyonrails.org/classes/ActionController/RateLimiting/ClassMethods.html). Rate limiting is **not** the same as lockout: it throttles requests without locking the account record.

### 2.5 Password Complexity Rules

`has_secure_password` only validates presence and ≤ 72 bytes. Minimum length, character requirements, and breach-checking are not added. Source: [has_secure_password API](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password).

### 2.6 Multi-Session Management UI

The `sessions` table captures `ip_address` and `user_agent`, so the data for a "Sign out all devices" or sessions list page is there. The UI and controller actions are not generated.

### Summary of Gaps

| Feature | Rails 8 Generator | Notes |
|---|---|---|
| Sign-up | ❌ | Must build |
| Email confirmation | ❌ | Must build (or use Devise/Rodauth) |
| Remember-me toggle | ⚠️ | Always permanent; no toggle |
| Account lockout | ❌ | `rate_limit` is partial mitigation |
| Password complexity | ❌ | Only presence + max length |
| Two-factor auth | ❌ | Must build |
| OmniAuth / Social login | ❌ | Must build |
| Multi-session management UI | ⚠️ | Data exists; no UI |
| Brute-force rate limiting | ✅ (Rails 8) | `rate_limit` in `SessionsController` |
| Timing-safe auth | ✅ | `authenticate_by` |
| Secure token-based password reset | ✅ | `generates_token_for` with expiry |
| Server-side session invalidation | ✅ | Session record deleted on sign-out |

---

## 3. Gems and Patterns to Fill the Gaps

### Option A: authentication-zero

**[authentication-zero](https://github.com/lazaronixon/authentication-zero)** is a generator gem built on the same Rails primitives that generates a more complete system. It uses `has_secure_password`, `generates_token_for`, `signed cookies`, etc. — the same foundation — but adds:

- Sign-up with email + password validations
- Email verification via token link
- Password-breach check via `pwned` gem (`--pwned` flag)
- Lockable mechanism (`--lockable` flag)
- Activity log / trackable (`--trackable` flag)
- Multiple sessions / devices management UI
- Two-factor authentication + recovery codes (`--two-factor` flag)
- WebAuthn hardware key support (`--webauthn` flag)
- Sudo (re-confirm password before sensitive actions)
- Passwordless login, OmniAuth, invite-only registration (optional flags)

Source: [authentication-zero README](https://github.com/lazaronixon/authentication-zero/blob/main/README.md).

**Tradeoff:** Like the Rails generator, it generates code into your app. You own it; it won't auto-update.

### Option B: Devise

**[Devise](https://github.com/heartcombo/devise)** is a Rails engine (10 opt-in modules) based on Warden:

| Module | What it provides |
|---|---|
| `DatabaseAuthenticatable` | Bcrypt password storage |
| `Registerable` | Sign-up/edit/delete account |
| `Confirmable` | Email confirmation with resend support |
| `Recoverable` | Password reset emails |
| `Rememberable` | "Remember me" cookie toggle |
| `Trackable` | Sign-in count, timestamps, IP |
| `Timeoutable` | Auto sign-out after inactivity |
| `Lockable` | Account lock after N failed attempts (unlock via email or timeout) |
| `Validatable` | Email/password format validations |
| `Omniauthable` | OmniAuth social login |

Source: [Devise README](https://github.com/heartcombo/devise/blob/main/README.md).

**Devise 5 supports Rails 7+** (including Rails 8). It also has Hotwire/Turbo integration configuration.

**Tradeoffs vs Rails 8 generator:**

| | Rails 8 Generator | Devise |
|---|---|---|
| Code ownership | Full — generated into your app | Engine; lives in the gem |
| Customisation | Easy — just edit the files | Requires overriding controllers/views |
| Features out of the box | Minimal | Complete |
| Session storage | DB-backed `sessions` table | Cookie-based (by default) |
| Transparency | High — readable, ~50 LOC concern | Low — "black box" |
| Maintenance | You maintain it | Gem maintainers |
| Warden dependency | No | Yes |
| Rails 8 support | Native | Yes (Devise 5) |

### Option C: Rodauth (via rodauth-rails)

**[Rodauth](https://rodauth.jeremyevans.net/)** is a Ruby authentication framework with the widest feature set (50+ authentication features). **[rodauth-rails](https://github.com/janko/rodauth-rails)** provides Rails integration. Features include all of the above plus: multi-factor auth, WebAuthn, OAuth, JWT, audit logging, etc.

For a content platform of this scope (blog posts, membership), Rodauth is likely over-engineered. It is worth knowing as the most feature-complete option.

---

## 4. Recommendation for Neurodiversity School

The stack is Rails 8, Phlex, Turbo. The app needs:

- **Registration** (must build regardless)
- **Email confirmation** (important for a membership site — prevents fake accounts and ensures reset emails reach real users)
- **Password reset** (provided by generator ✅)
- **Rate limiting** on sign-in (provided by Rails 8 ✅)
- **Multi-device session management** (data available, UI to build)

**Recommended path:** Start with the **Rails 8 generator** (`bin/rails generate authentication`) and layer on the missing pieces manually, in this order:

1. `RegistrationsController` + sign-up form (10–20 LOC).
2. Email confirmation using `generates_token_for :email_confirmation, expires_in: 2.days` — keeps the same code style as password reset.
3. `rate_limit` on `SessionsController#create` to mitigate brute force.
4. Password minimum length validation on the `User` model.

This gives full code ownership and keeps complexity proportional to the scope. Devise adds value when you need Lockable, Trackable, and OmniAuth together — if those needs arise, migrating to Devise later is straightforward since both use `has_secure_password` and the `users` table.

**If email confirmation must be built quickly:** `authentication-zero` (with no flags except `--lockable`) generates all of this in one command and produces code you can read and adapt to Phlex views.

---

## 5. Key Sources

- [Rails Security Guide — Authentication](https://guides.rubyonrails.org/security.html#authentication)
- [Rails authentication_generator.rb (source)](https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/authentication/authentication_generator.rb)
- [authentication concern template (source)](https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/authentication/templates/app/controllers/concerns/authentication.rb.tt)
- [has_secure_password API](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password)
- [authenticate_by API](https://api.rubyonrails.org/classes/ActiveRecord/SecurePassword/ClassMethods.html)
- [ActionController::RateLimiting API](https://edgeapi.rubyonrails.org/classes/ActionController/RateLimiting/ClassMethods.html)
- [Devise README](https://github.com/heartcombo/devise/blob/main/README.md)
- [Devise — How to add :confirmable](https://github.com/heartcombo/devise/wiki/How-To:-Add-:confirmable-to-Users)
- [authentication-zero README](https://github.com/lazaronixon/authentication-zero/blob/main/README.md)
