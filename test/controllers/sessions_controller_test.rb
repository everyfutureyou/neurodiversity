require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user.update!(confirmed_at: Time.current)
  end

  test "new renders sign in page" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to posts_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "create with unconfirmed account redirects" do
    @user.update!(confirmed_at: nil)
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to new_session_path
  end

  test "destroy" do
    sign_in_as(@user)
    delete session_path
    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end
end
