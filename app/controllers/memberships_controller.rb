# frozen_string_literal: true

class MembershipsController < ApplicationController
  before_action :require_active_membership, only: :show
  before_action :redirect_existing_member, only: :new

  def new
    render Views::Memberships::New.new
  end

  def create
    amount_cents = (params.dig(:membership, :amount_euros).to_f * 100).round

    unless valid_pwyw_amount?(amount_cents)
      return render Views::Memberships::New.new, status: :unprocessable_entity
    end

    service = StripeService.new(current_user)
    customer_id = service.find_or_create_customer

    if amount_cents.zero?
      activate_free_membership(service, customer_id)
    else
      redirect_to_stripe_checkout(service, customer_id, amount_cents)
    end
  end

  def show
    render Views::Memberships::Show.new(membership: current_user.membership)
  end

  def success
    render Views::Memberships::Success.new
  end

  private

  # Stripe EUR minimum is €0.50; allow only 0 or ≥50 cents
  def valid_pwyw_amount?(cents)
    cents.zero? || cents >= 50
  end

  def activate_free_membership(service, customer_id)
    subscription = service.create_free_subscription(customer_id)
    membership = current_user.create_membership!(
      status: :active,
      amount_cents: 0,
      stripe_subscription_id: subscription.id
    )
    current_user.update!(role: :member)
    redirect_to success_membership_path, notice: t("memberships.activated_free")
  end

  def redirect_to_stripe_checkout(service, customer_id, amount_cents)
    checkout_url = service.create_checkout_session(
      customer_id,
      amount_cents: amount_cents,
      success_url: success_membership_url,
      cancel_url: new_membership_url
    )
    redirect_to checkout_url, allow_other_host: true
  end

  def require_active_membership
    unless current_user.membership&.active?
      redirect_to new_membership_path
    end
  end

  def redirect_existing_member
    if current_user.membership&.active?
      redirect_to membership_path
    end
  end
end
