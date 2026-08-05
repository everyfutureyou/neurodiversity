require "test_helper"

class SitemapControllerTest < ActionDispatch::IntegrationTest
  test "GET /sitemap.xml returns success" do
    get "/sitemap.xml"
    assert_response :success
  end

  test "sitemap response has XML content type" do
    get "/sitemap.xml"
    assert_match "application/xml", response.content_type
  end

  test "sitemap includes published post URLs for both locales" do
    post = posts(:published_en)
    get "/sitemap.xml"
    assert_includes response.body, post_url(post, locale: :en)
    assert_includes response.body, post_url(post, locale: :de)
  end

  test "sitemap does not include draft posts" do
    get "/sitemap.xml"
    assert_not_includes response.body, posts(:draft).slug
  end

  test "sitemap includes the blog index for both locales" do
    get "/sitemap.xml"
    assert_includes response.body, posts_url(locale: :en)
    assert_includes response.body, posts_url(locale: :de)
  end
end
