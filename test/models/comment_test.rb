require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def valid_comment
    Comment.new(
      post: posts(:published_en),
      user: users(:member),
      body: "A thoughtful comment."
    )
  end

  test "valid with required attributes" do
    assert valid_comment.valid?
  end

  test "requires body" do
    comment = valid_comment
    comment.body = ""
    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "requires post" do
    comment = valid_comment
    comment.post = nil
    assert_not comment.valid?
  end

  test "requires user" do
    comment = valid_comment
    comment.user = nil
    assert_not comment.valid?
  end

  test "root? is true when parent_id is nil" do
    assert comments(:root_comment).root?
  end

  test "root? is false when parent_id is set" do
    assert_not comments(:reply_comment).root?
  end

  test "replies association returns child comments" do
    parent = comments(:root_comment)
    reply = comments(:reply_comment)
    assert_includes parent.replies, reply
  end

  test "parent association returns the parent comment" do
    reply = comments(:reply_comment)
    assert_equal comments(:root_comment), reply.parent
  end

  test "for_post scope returns comments for the given post" do
    post = posts(:published_en)
    result = Comment.for_post(post)
    assert_includes result, comments(:root_comment)
    assert_includes result, comments(:reply_comment)
  end

  test "roots scope returns only top-level comments" do
    result = Comment.roots
    assert_includes result, comments(:root_comment)
    assert_not_includes result, comments(:reply_comment)
  end

  test "oldest_first scope orders by created_at ascending" do
    result = Comment.oldest_first.to_a
    assert result.first.created_at <= result.last.created_at
  end
end
