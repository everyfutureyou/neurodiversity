require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def valid_message
    Message.new(
      user: users(:member),
      subject: "A question",
      body: "I have a question about the platform."
    )
  end

  test "valid with required attributes" do
    assert valid_message.valid?
  end

  test "requires subject" do
    msg = valid_message
    msg.subject = ""
    assert_not msg.valid?
    assert_includes msg.errors[:subject], "can't be blank"
  end

  test "requires body" do
    msg = valid_message
    msg.body = ""
    assert_not msg.valid?
    assert_includes msg.errors[:body], "can't be blank"
  end

  test "requires user" do
    msg = valid_message
    msg.user = nil
    assert_not msg.valid?
  end

  test "newest_first scope orders by created_at descending" do
    older = Message.create!(user: users(:member), subject: "Old", body: "Old body", created_at: 1.hour.ago)
    newer = Message.create!(user: users(:member), subject: "New", body: "New body", created_at: 1.minute.ago)
    result = Message.newest_first.to_a
    assert result.index(newer) < result.index(older)
  end
end
