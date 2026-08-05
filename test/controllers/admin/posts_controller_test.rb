require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @post = posts(:published_en)
    @draft = posts(:draft)
  end

  # Access control
  test "guest is redirected from admin posts" do
    get admin_posts_path
    assert_redirected_to new_session_path
  end

  test "non-admin member is redirected from admin posts" do
    sign_in_as users(:member)
    get admin_posts_path
    assert_redirected_to root_path
  end

  test "policy enforced under german locale" do
    sign_in_as users(:member)
    get admin_posts_path(locale: :de)
    assert_redirected_to root_path
  end

  test "admin can access posts index" do
    sign_in_as @admin
    get admin_posts_path
    assert_response :success
  end

  # CRUD
  test "admin can create a post" do
    sign_in_as @admin
    assert_difference "Post.count" do
      post admin_posts_path, params: {
        post: {
          slug: "new-post",
          title: { en: "New Post", de: "Neuer Beitrag" },
          body: { en: "Content", de: "Inhalt" }
        }
      }
    end
    assert_redirected_to admin_posts_path
  end

  test "admin can edit a post" do
    sign_in_as @admin
    patch admin_post_path(@post), params: {
      post: { title: { en: "Updated Title" } }
    }
    assert_redirected_to admin_posts_path
    assert_equal "Updated Title", @post.reload.title["en"]
  end

  test "admin can publish a draft post" do
    sign_in_as @admin
    assert_nil @draft.published_at
    patch publish_admin_post_path(@draft)
    assert_redirected_to admin_posts_path
    assert @draft.reload.published?
  end

  test "admin can unpublish a published post" do
    sign_in_as @admin
    assert @post.published?
    patch unpublish_admin_post_path(@post)
    assert_redirected_to admin_posts_path
    assert_not @post.reload.published?
  end

  test "admin can delete a post" do
    sign_in_as @admin
    assert_difference "Post.count", -1 do
      delete admin_post_path(@post)
    end
    assert_redirected_to admin_posts_path
  end
end
