require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "default role is guest" do
    user = User.create!(email_address: "new@example.com", password: "password")
    assert user.guest?
    assert_not user.member?
    assert_not user.admin?
  end

  test "role can be promoted to member" do
    user = users(:one)
    user.update!(role: :member)
    assert user.member?
    assert_not user.guest?
  end

  test "role can be promoted to admin" do
    user = users(:one)
    user.update!(role: :admin)
    assert user.admin?
  end

  test "at_least_member? is true for member and admin" do
    assert users(:member).at_least_member?
    assert users(:admin).at_least_member?
    assert_not users(:one).at_least_member?
  end
end
