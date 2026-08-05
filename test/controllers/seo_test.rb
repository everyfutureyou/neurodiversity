require "test_helper"

# Tests SEO meta tags, hreflang alternate links, and canonical URLs
# across public-facing pages. Seams: HTTP response body.
class SeoTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:published_en)
  end

  # --- description on every page ---

  test "home page includes meta description" do
    get "/en"
    assert_response :success
    assert_select "meta[name='description']"
  end

  test "post index includes meta description" do
    get posts_path
    assert_response :success
    assert_select "meta[name='description']"
  end

  test "post show includes meta description" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[name='description']"
  end

  # --- canonical URL on every page ---

  test "home page includes canonical link" do
    get "/en"
    assert_response :success
    assert_select "link[rel='canonical']"
  end

  test "post index includes canonical link" do
    get posts_path
    assert_response :success
    assert_select "link[rel='canonical']"
  end

  test "post show includes canonical link" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "link[rel='canonical']"
  end

  # --- hreflang alternate links on every page ---

  test "home page includes hreflang link for de" do
    get "/en"
    assert_response :success
    assert_select "link[rel='alternate'][hreflang='de']"
  end

  test "home page includes hreflang link for en" do
    get "/en"
    assert_response :success
    assert_select "link[rel='alternate'][hreflang='en']"
  end

  test "post show includes hreflang links for both locales" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "link[rel='alternate'][hreflang='de']"
    assert_select "link[rel='alternate'][hreflang='en']"
  end

  # --- OpenGraph tags on post show ---

  test "post show includes og:title" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[property='og:title']"
  end

  test "post show includes og:description" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[property='og:description']"
  end

  test "post show includes og:type article" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[property='og:type'][content='article']"
  end

  test "post show includes og:url" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[property='og:url']"
  end

  # --- Twitter Card tags on post show ---

  test "post show includes twitter:card" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[name='twitter:card']"
  end

  test "post show includes twitter:title" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[name='twitter:title']"
  end

  test "post show includes twitter:description" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "meta[name='twitter:description']"
  end

  # --- JSON-LD Article on post show ---

  test "post show includes JSON-LD Article script tag" do
    get post_path(@post.slug)
    assert_response :success
    assert_select "script[type='application/ld+json']"
    json_ld = JSON.parse(css_select("script[type='application/ld+json']").first.text)
    assert_equal "Article", json_ld["@type"]
    assert_equal @post.localized_title, json_ld["headline"]
  end

  # --- no OG/JSON-LD on non-post pages ---

  test "home page does not include og:type article" do
    get "/en"
    assert_response :success
    assert_select "meta[property='og:type'][content='article']", count: 0
  end
end
