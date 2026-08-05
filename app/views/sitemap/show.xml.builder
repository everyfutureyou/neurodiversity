xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset(
  xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9",
  "xmlns:xhtml": "http://www.w3.org/1999/xhtml"
) do
  locales = I18n.available_locales.map(&:to_s)

  # Blog index pages in each locale
  locales.each do |locale|
    xml.url do
      xml.loc posts_url(locale: locale)
      xml.changefreq "daily"
      xml.priority "0.8"
      locales.each do |alt|
        xml.xhtml :link, rel: "alternate", hreflang: alt, href: posts_url(locale: alt)
      end
    end
  end

  # Individual published posts
  @posts.each do |post|
    locales.each do |locale|
      next if post.localized_title(locale).blank?

      xml.url do
        xml.loc post_url(post, locale: locale)
        xml.lastmod post.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        xml.changefreq "weekly"
        xml.priority "0.7"
        locales.each do |alt|
          next if post.localized_title(alt).blank?
          xml.xhtml :link, rel: "alternate", hreflang: alt, href: post_url(post, locale: alt)
        end
      end
    end
  end
end
