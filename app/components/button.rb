# frozen_string_literal: true

class Components::Button < Components::Base
  VARIANTS = {
    primary: "bg-(--color-brand) hover:bg-(--color-brand-hover) text-white",
    secondary: "bg-(--color-surface) hover:bg-(--color-border) text-(--color-ink) border border-(--color-border)",
    danger: "bg-(--color-danger) hover:opacity-90 text-white",
    ghost: "hover:bg-(--color-surface) text-(--color-ink-muted) hover:text-(--color-ink)"
  }.freeze

  SIZES = {
    sm: "px-3 py-1.5 text-sm",
    md: "px-4 py-2 text-base",
    lg: "px-6 py-3 text-lg"
  }.freeze

  def initialize(label = nil, href: nil, variant: :primary, size: :md, type: "button", classes: nil, **attrs)
    @label = label
    @href = href
    @variant = variant
    @size = size
    @type = type
    @extra_classes = classes
    @attrs = attrs
  end

  def view_template(&content)
    base_classes = [
      "inline-flex items-center justify-center font-medium rounded-(--radius-md)",
      "transition-colors focus:outline-none focus:ring-2 focus:ring-(--color-brand)",
      "focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed",
      VARIANTS.fetch(@variant),
      SIZES.fetch(@size),
      @extra_classes
    ].compact.join(" ")

    if @href
      a(href: @href, class: base_classes, **@attrs) do
        content ? yield : plain(@label)
      end
    else
      button(type: @type, class: base_classes, **@attrs) do
        content ? yield : plain(@label)
      end
    end
  end
end
