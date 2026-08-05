# frozen_string_literal: true

# Renders all SEO-related <head> tags: description, canonical, hreflang, OG, Twitter, JSON-LD.
class Components::MetaTags < Components::Base
  LOCALES = %w[de en].freeze

  def initialize(title:, description: nil, og: nil, json_ld: nil)
    @title = title
    @description = description
    @og = og
    @json_ld = json_ld
  end

  def view_template
    meta(name: "description", content: @description) if @description.present?

    link(rel: "canonical", href: canonical_url)

    LOCALES.each do |locale|
      link(rel: "alternate", hreflang: locale, href: hreflang_url(locale))
    end

    render_og if @og
    render_json_ld if @json_ld
  end

  private

  def canonical_url
    view_context.request.original_url
  end

  def hreflang_url(locale)
    base = view_context.request.base_url
    path = view_context.request.path.sub(Regexp.new("\\A/(#{LOCALES.join("|")})(?=/|$)"), "")
    "#{base}/#{locale}#{path.presence || "/"}"
  end

  def render_og
    meta(property: "og:title", content: @og[:title] || @title)
    meta(property: "og:description", content: @og[:description] || @description)
    meta(property: "og:type", content: @og[:type] || "website")
    meta(property: "og:url", content: @og[:url] || canonical_url)
    meta(property: "og:image", content: @og[:image]) if @og[:image].present?

    meta(name: "twitter:card", content: "summary_large_image")
    meta(name: "twitter:title", content: @og[:title] || @title)
    meta(name: "twitter:description", content: @og[:description] || @description)
    meta(name: "twitter:image", content: @og[:image]) if @og[:image].present?
  end

  def render_json_ld
    # raw requires a safe string; json_escape prevents </script> injection
    script(type: "application/ld+json") { raw ERB::Util.json_escape(@json_ld.to_json).html_safe }
  end
end
