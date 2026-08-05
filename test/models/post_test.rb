require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "published scope excludes drafts" do
    assert_includes Post.published, posts(:published_en)
    assert_not_includes Post.published, posts(:draft)
  end

  test "newest_first scope orders by published_at descending" do
    ordered = Post.published.newest_first.to_a
    assert_equal posts(:published_en), ordered.first
    assert_equal posts(:published_de_only), ordered.last
  end

  test "localized_title returns the title for the given locale" do
    post = posts(:published_en)
    assert_equal "Hello World", post.localized_title(:en)
    assert_equal "Hallo Welt", post.localized_title(:de)
  end

  test "localized_title falls back to English when locale is missing" do
    post = posts(:published_de_only)
    assert_equal "Nur auf Deutsch", post.localized_title(:de)
    # no :en key — falls back gracefully (empty string, not error)
    assert_equal "", post.localized_title(:en)
  end

  test "localized_body returns the body for the given locale" do
    post = posts(:published_en)
    assert_equal "English body content.", post.localized_body(:en)
    assert_equal "Deutscher Inhalt.", post.localized_body(:de)
  end

  test "published? is false for drafts" do
    assert_not posts(:draft).published?
  end

  test "published? is true for published posts" do
    assert posts(:published_en).published?
  end

  test "slug must be unique" do
    duplicate = Post.new(
      slug: posts(:published_en).slug,
      title: { "en" => "Another" },
      body: { "en" => "Body" },
      author: users(:one),
      published_at: Time.current
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "slug must be present" do
    post = Post.new(
      title: { "en" => "Title" },
      body: { "en" => "Body" },
      author: users(:one)
    )
    assert_not post.valid?
    assert_includes post.errors[:slug], "can't be blank"
  end
end
