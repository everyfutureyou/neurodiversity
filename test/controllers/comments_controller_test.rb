require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:published_en)
    @member = users(:member)
  end

  test "comment on another user's post enqueues notification email" do
    sign_in_as @member
    assert_emails 1 do
      post post_comments_path(@post.slug), params: { comment: { body: "Great article!" } }
    end
  end

  test "comment on own post does not send notification email" do
    sign_in_as users(:one) # one is the post author
    assert_no_emails do
      post post_comments_path(@post.slug), params: { comment: { body: "My own post." } }
    end
  end

  # --- CREATE ---

  test "member can post a comment" do
    sign_in_as @member
    assert_difference "Comment.count", 1 do
      post post_comments_path(@post.slug), params: { comment: { body: "Great article!" } }
    end
    comment = Comment.last
    assert_equal "Great article!", comment.body
    assert_equal @post, comment.post
    assert_equal @member, comment.user
  end

  test "member comment create redirects back to post on HTML request" do
    sign_in_as @member
    post post_comments_path(@post.slug), params: { comment: { body: "Nice post!" } }
    assert_redirected_to post_path(@post.slug)
  end

  test "member comment create returns turbo stream on turbo request" do
    sign_in_as @member
    post post_comments_path(@post.slug),
      params: { comment: { body: "Turbo comment!" } },
      headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "member can post a reply to an existing comment" do
    sign_in_as @member
    parent = comments(:root_comment)
    assert_difference "Comment.count", 1 do
      post post_comments_path(@post.slug),
        params: { comment: { body: "A reply.", parent_id: parent.id } }
    end
    assert_equal parent.id, Comment.last.parent_id
  end

  test "guest cannot post a comment and is redirected to sign-in" do
    assert_no_difference "Comment.count" do
      post post_comments_path(@post.slug), params: { comment: { body: "Sneaky" } }
    end
    assert_redirected_to new_session_path
  end

  test "unconfirmed user cannot post a comment" do
    sign_in_as users(:two)
    assert_no_difference "Comment.count" do
      post post_comments_path(@post.slug), params: { comment: { body: "Sneaky" } }
    end
    assert_response :redirect
  end

  test "member cannot post blank comment" do
    sign_in_as @member
    assert_no_difference "Comment.count" do
      post post_comments_path(@post.slug), params: { comment: { body: "" } }
    end
    assert_response :redirect
  end

  # --- DESTROY (admin only) ---

  test "admin can delete a comment" do
    sign_in_as users(:admin)
    comment = comments(:reply_comment)
    assert_difference "Comment.count", -1 do
      delete post_comment_path(@post.slug, comment)
    end
    assert_redirected_to post_path(@post.slug)
  end

  test "member cannot delete a comment" do
    sign_in_as @member
    comment = comments(:root_comment)
    assert_no_difference "Comment.count" do
      delete post_comment_path(@post.slug, comment)
    end
    assert_response :redirect
  end
end
