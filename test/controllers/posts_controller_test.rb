require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published = posts(:published_en)
    @draft = posts(:draft)
  end

  test "index lists published posts" do
    get posts_path
    assert_response :success
    assert_includes response.body, "Hello World"
  end

  test "index does not list drafts" do
    get posts_path
    assert_response :success
    assert_not_includes response.body, "Draft Post"
  end

  test "show renders a published post" do
    get post_path(@published.slug)
    assert_response :success
    assert_includes response.body, "Hello World"
    assert_includes response.body, "English body content."
  end

  test "show includes author on the page" do
    get post_path(@published.slug)
    assert_response :success
    assert_includes response.body, @published.author.email_address
  end

  test "show returns 404 for a draft post" do
    get post_path(@draft.slug)
    assert_response :not_found
  end

  test "show returns 404 for an unknown slug" do
    get post_path("does-not-exist")
    assert_response :not_found
  end

  test "index in German locale renders German titles" do
    get posts_path(locale: :de)
    assert_response :success
    # published_de_only fixture has German title but no English title
    assert_includes response.body, "Nur auf Deutsch"
    assert_not_includes response.body, "Hello World"
  end
end
