require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new renders registration form" do
    get new_registration_path
    assert_response :success
  end

  test "create with valid params sends confirmation email and shows confirm page" do
    assert_emails 1 do
      post registrations_path, params: {
        user: { email_address: "new@example.com", password: "securepassword123",
                password_confirmation: "securepassword123" }
      }
    end
    assert_response :success
    user = User.find_by(email_address: "new@example.com")
    assert user.present?
    assert_not user.confirmed?
  end

  test "create with invalid params re-renders form" do
    post registrations_path, params: {
      user: { email_address: "", password: "", password_confirmation: "" }
    }
    assert_response :unprocessable_entity
  end

  test "confirm with valid token sends welcome email" do
    user = User.create!(email_address: "welcome@example.com",
                        password: "securepassword123",
                        password_confirmation: "securepassword123")
    token = user.generate_token_for(:email_confirmation)

    assert_emails 1 do
      get confirm_registrations_path(token: token)
    end
  end

  test "confirm with valid token activates account and signs in" do
    user = User.create!(email_address: "confirm@example.com",
                        password: "securepassword123",
                        password_confirmation: "securepassword123")
    token = user.generate_token_for(:email_confirmation)

    get confirm_registrations_path(token: token)
    assert_redirected_to root_path

    user.reload
    assert user.confirmed?
    assert cookies[:session_id]
  end

  test "confirm with invalid token redirects to registration" do
    get confirm_registrations_path(token: "invalid")
    assert_redirected_to new_registration_path
  end
end
