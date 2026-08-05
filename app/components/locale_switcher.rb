# frozen_string_literal: true

class Components::LocaleSwitcher < Components::Base
  LOCALES = %w[de en].freeze

  def template
    div(class: "flex items-center gap-1") do
      LOCALES.each do |locale|
        active = locale == I18n.locale.to_s
        a(
          href: locale_switch_path(locale),
          class: locale_link_classes(active),
          aria_current: active ? "true" : nil,
          aria_label: t("locale_switcher.switch_to_#{locale}")
        ) do
          plain locale.upcase
        end
      end
    end
  end

  private

  def locale_link_classes(active)
    base = "text-xs font-medium px-1.5 py-0.5 rounded-(--radius-sm) transition-colors"
    if active
      "#{base} bg-(--color-brand-subtle) text-(--color-brand)"
    else
      "#{base} text-(--color-ink-muted) hover:text-(--color-ink)"
    end
  end

  def locale_switch_path(locale)
    current_path = view_context.request.path
    path_without_locale = current_path.sub(%r{\A/(de|en)(?=/|$)}, "")
    "/#{locale}#{path_without_locale.presence || "/"}"
  end
end
