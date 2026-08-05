require "test_helper"

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  # new

  test "new renders the PWYW widget" do
    get new_membership_path
    assert_response :success
  end

  test "new redirects unauthenticated visitor to sign in" do
    sign_out
    get new_membership_path
    assert_redirected_to new_session_path
  end

  test "new redirects an existing active member to their membership" do
    @user.update!(role: :member)
    @user.create_membership!(status: :active, amount_cents: 0)
    get new_membership_path
    assert_redirected_to membership_path
  end

  # create (free track)

  test "create with 0 euros activates membership immediately without Stripe redirect" do
    customer_stub = Struct.new(:id).new("cus_free")
    price_stub    = Struct.new(:id).new("price_free")
    sub_stub      = Struct.new(:id).new("sub_free")

    with_stub(Stripe::Customer, :create, customer_stub) do
      with_stub(Stripe::Price, :create, price_stub) do
        with_stub(Stripe::Subscription, :create, sub_stub) do
          post membership_path, params: { membership: { amount_euros: "0" } }
        end
      end
    end

    assert_redirected_to success_membership_path
    @user.reload
    assert @user.member?, "user should be promoted to member role"
    assert @user.membership.active?, "membership status should be active"
    assert_equal 0, @user.membership.amount_cents
    assert_equal "sub_free", @user.membership.stripe_subscription_id
  end

  test "create with amount between 1 and 49 cents is rejected" do
    post membership_path, params: { membership: { amount_euros: "0.25" } }
    assert_response :unprocessable_entity
  end

  # create (paid track)

  test "create with 5 euros redirects to Stripe Checkout" do
    checkout_url  = "https://checkout.stripe.com/test"
    customer_stub = Struct.new(:id).new("cus_paid")
    price_stub    = Struct.new(:id).new("price_paid")
    session_stub  = Struct.new(:url).new(checkout_url)

    with_stub(Stripe::Customer, :create, customer_stub) do
      with_stub(Stripe::Price, :create, price_stub) do
        with_stub(Stripe::Checkout::Session, :create, session_stub) do
          post membership_path, params: { membership: { amount_euros: "5.00" } }
        end
      end
    end

    assert_redirected_to checkout_url
  end

  # show

  test "show renders membership status for active member" do
    @user.update!(role: :member)
    @user.create_membership!(status: :active, amount_cents: 0)
    get membership_path
    assert_response :success
  end

  test "show redirects guest to new membership page" do
    get membership_path
    assert_redirected_to new_membership_path
  end

  # success

  test "success renders confirmation page" do
    get success_membership_path
    assert_response :success
  end
end
