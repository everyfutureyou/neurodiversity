# frozen_string_literal: true

class Views::Registrations::Confirm < Views::Base
  def page_title = t("registrations.confirm.title")

  def page_content
    div(class: "max-w-md mx-auto text-center py-16 space-y-4") do
      render Components::Heading.new(t("registrations.confirm.heading"), level: 1)
      p(class: "text-(--color-ink-muted)") { t("registrations.confirm.body") }
    end
  end
end
