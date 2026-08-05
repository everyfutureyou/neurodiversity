# frozen_string_literal: true

module Webhooks
  class StripeController < ActionController::Base
    # Stripe webhooks must not be CSRF-protected; raw body is needed for signature verification.
    skip_before_action :verify_authenticity_token
    before_action :verify_stripe_signature

    def create
      case @event.type
      when "checkout.session.completed"
        handle_checkout_completed(@event.data.object)
      when "customer.subscription.created"
        handle_subscription_created(@event.data.object)
      when "customer.subscription.updated"
        handle_subscription_updated(@event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(@event.data.object)
      end

      head :ok
    end

    private

    def verify_stripe_signature
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

      @event = Stripe::Webhook.construct_event(payload, sig_header, secret)
    rescue Stripe::SignatureVerificationError
      head :bad_request
    end

    def handle_checkout_completed(session)
      user = User.find_by(stripe_customer_id: session["customer"])
      return unless user

      grant_membership(user,
        stripe_subscription_id: session["subscription"],
        amount_cents: session["amount_total"].to_i
      )
    end

    def handle_subscription_created(subscription)
      # Free subscriptions (€0) are activated in the controller synchronously.
      # This handler is a safety net for any subscription not yet recorded.
      user = User.find_by(stripe_customer_id: subscription["customer"])
      return unless user
      return unless subscription["status"] == "active"

      membership = user.membership || user.build_membership
      return if membership.active? && membership.stripe_subscription_id.present?

      grant_membership(user,
        stripe_subscription_id: subscription["id"],
        amount_cents: 0
      )
    end

    def handle_subscription_updated(subscription)
      membership = Membership.find_by(stripe_subscription_id: subscription["id"])
      return unless membership

      stripe_status = subscription["status"]
      local_status = stripe_status_to_local(stripe_status)
      membership.update!(status: local_status) if local_status
    end

    def handle_subscription_deleted(subscription)
      membership = Membership.find_by(stripe_subscription_id: subscription["id"])
      return unless membership

      membership.update!(status: :canceled)
      revoke_membership(membership.user)
    end

    def grant_membership(user, stripe_subscription_id:, amount_cents:)
      membership = user.membership || user.build_membership
      membership.update!(status: :active, stripe_subscription_id: stripe_subscription_id, amount_cents: amount_cents)
      user.update!(role: :member) unless user.member? || user.admin?
    end

    def revoke_membership(user)
      user.update!(role: :guest) unless user.admin?
    end

    STRIPE_STATUS_MAP = {
      "active" => :active,
      "past_due" => :past_due,
      "canceled" => :canceled,
      "unpaid" => :canceled,
      "incomplete_expired" => :canceled
    }.freeze

    def stripe_status_to_local(stripe_status)
      STRIPE_STATUS_MAP[stripe_status]
    end
  end
end
