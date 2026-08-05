require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @member = users(:member)
  end

  test "member can GET the contact form" do
    sign_in_as @member
    get new_message_path
    assert_response :success
  end

  test "guest cannot GET the contact form" do
    get new_message_path
    assert_redirected_to new_session_path
  end

  test "member can submit a message" do
    sign_in_as @member
    assert_difference "Message.count", 1 do
      post messages_path, params: { message: { subject: "Hello team", body: "I have a question." } }
    end
    msg = Message.last
    assert_equal "Hello team", msg.subject
    assert_equal @member, msg.user
    assert_redirected_to root_path
  end

  test "member cannot submit a message with blank subject" do
    sign_in_as @member
    assert_no_difference "Message.count" do
      post messages_path, params: { message: { subject: "", body: "Body here." } }
    end
    assert_response :unprocessable_entity
  end

  test "member cannot submit a message with blank body" do
    sign_in_as @member
    assert_no_difference "Message.count" do
      post messages_path, params: { message: { subject: "Subject", body: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "guest cannot POST a message" do
    assert_no_difference "Message.count" do
      post messages_path, params: { message: { subject: "Hello", body: "Body" } }
    end
    assert_redirected_to new_session_path
  end
end
