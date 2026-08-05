# frozen_string_literal: true

class Views::Memberships::New < Views::Base
  def page_title = t("memberships.new.title")

  def page_content
    div(class: "max-w-lg mx-auto py-12 space-y-8") do
      render Components::Heading.new(t("memberships.new.heading"), level: 1)
      p(class: "text-(--color-ink-muted)") { t("memberships.new.description") }
      render Components::PwywWidget.new
    end
  end
end
