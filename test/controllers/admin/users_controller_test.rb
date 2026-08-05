require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "guest is redirected from admin users" do
    get admin_users_path
    assert_redirected_to new_session_path
  end

  test "non-admin is redirected from admin users" do
    sign_in_as users(:member)
    get admin_users_path
    assert_redirected_to root_path
  end

  test "admin can view user list" do
    sign_in_as users(:admin)
    get admin_users_path
    assert_response :success
    assert_includes response.body, "admin@example.com"
    assert_includes response.body, "member@example.com"
  end
end
