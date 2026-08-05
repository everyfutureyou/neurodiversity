require "test_helper"

class Admin::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  test "admin can list messages" do
    sign_in_as @admin
    get admin_messages_path
    assert_response :success
    assert_includes response.body, messages(:one).subject
  end

  test "member cannot access admin messages" do
    sign_in_as users(:member)
    get admin_messages_path
    assert_redirected_to root_path
  end

  test "guest cannot access admin messages" do
    get admin_messages_path
    assert_redirected_to new_session_path
  end

  test "admin can delete a message" do
    sign_in_as @admin
    assert_difference "Message.count", -1 do
      delete admin_message_path(messages(:one))
    end
    assert_redirected_to admin_messages_path
  end
end
