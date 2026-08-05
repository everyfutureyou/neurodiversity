require "test_helper"

class Webhooks::StripeControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(stripe_customer_id: "cus_test123")
  end

  # signature verification

  test "rejects request with invalid Stripe signature" do
    with_stub(Stripe::Webhook, :construct_event, nil) do
      Stripe::Webhook.define_singleton_method(:construct_event) do |*_|
        raise Stripe::SignatureVerificationError.new("bad sig", "header")
      end
      post webhooks_stripe_path,
        params: "{}",
        headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "bad" }
      assert_response :bad_request
    end
  end

  # checkout.session.completed

  test "checkout.session.completed activates membership for paid subscription" do
    subscription_id = "sub_paid123"
    amount_cents = 1000
    event = stripe_event("checkout.session.completed", {
      "customer" => @user.stripe_customer_id,
      "subscription" => subscription_id,
      "amount_total" => amount_cents
    })

    deliver_event(event)

    @user.reload
    assert @user.member?, "role should be promoted to member"
    assert @user.membership.active?
    assert_equal subscription_id, @user.membership.stripe_subscription_id
    assert_equal amount_cents, @user.membership.amount_cents
  end

  # customer.subscription.deleted

  test "customer.subscription.deleted revokes membership" do
    @user.create_membership!(status: :active, amount_cents: 0, stripe_subscription_id: "sub_todelete")
    @user.update!(role: :member)

    event = stripe_event("customer.subscription.deleted", {
      "id" => "sub_todelete",
      "customer" => @user.stripe_customer_id
    })

    deliver_event(event)

    @user.reload
    assert @user.guest?, "role should be demoted to guest"
    assert @user.membership.canceled?
  end

  # customer.subscription.updated

  test "customer.subscription.updated to past_due updates status" do
    @user.create_membership!(status: :active, amount_cents: 500, stripe_subscription_id: "sub_update")
    @user.update!(role: :member)

    event = stripe_event("customer.subscription.updated", {
      "id" => "sub_update",
      "customer" => @user.stripe_customer_id,
      "status" => "past_due"
    })

    deliver_event(event)

    @user.membership.reload
    assert @user.membership.past_due?
  end

  private

  def stripe_event(type, object_attrs)
    Stripe::Event.construct_from({
      "type" => type,
      "data" => { "object" => object_attrs }
    })
  end

  def deliver_event(event)
    with_stub(Stripe::Webhook, :construct_event, event) do
      post webhooks_stripe_path,
        params: event.to_json,
        headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "stub" }
    end
    assert_response :ok
  end
end
