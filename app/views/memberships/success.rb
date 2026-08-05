# frozen_string_literal: true

class Views::Memberships::Success < Views::Base
  def page_title = t("memberships.success.title")

  def page_content
    div(class: "max-w-lg mx-auto py-16 text-center space-y-6") do
      render Components::Heading.new(t("memberships.success.heading"), level: 1)
      p(class: "text-(--color-ink-muted)") { t("memberships.success.body") }
      render Components::Button.new(t("memberships.success.cta"), href: posts_path)
    end
  end
end
