# frozen_string_literal: true

class Components::ApplicationLayout < Components::Base
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::JavascriptImportmapTags

  def initialize(title: nil, theme: "default")
    @title = title
    @theme = theme
  end

  def view_template(&content)
    doctype
    html(lang: I18n.locale.to_s, data_theme: @theme) do
      head do
        meta charset: "utf-8"
        title { @title || t("app.name") }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        meta name: "apple-mobile-web-app-capable", content: "yes"
        csrf_meta_tags
        csp_meta_tag
        stylesheet_link_tag "tailwind.css", "data-turbo-track": "reload"
        javascript_importmap_tags
      end
      body(class: "bg-(--color-canvas) text-(--color-ink) min-h-screen font-sans") do
        render Components::Nav.new
        render_flash
        main(class: "container mx-auto px-4 py-8", &content)
      end
    end
  end

  private

  def render_flash
    flash = view_context.flash
    return if flash.empty?

    div(class: "container mx-auto px-4 pt-4") do
      flash.each do |type, message|
        div(class: flash_classes(type)) { plain message }
      end
    end
  end

  def flash_classes(type)
    base = "rounded-(--radius-md) px-4 py-3 text-sm mb-2"
    case type.to_s
    when "notice" then "#{base} bg-(--color-brand-subtle) text-(--color-brand) border border-(--color-brand)"
    when "alert" then "#{base} bg-red-50 text-(--color-danger) border border-red-200"
    else "#{base} bg-(--color-surface) text-(--color-ink) border border-(--color-border)"
    end
  end
end
