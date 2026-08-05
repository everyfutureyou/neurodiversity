# frozen_string_literal: true

class Views::Home::Index < Views::Base
  def page_title = t("home.title")

  def page_content
    div(class: "max-w-2xl mx-auto text-center py-16 space-y-6") do
      render Components::Heading.new(t("home.headline"), level: 1)
      p(class: "text-(--color-ink-muted) text-lg") { t("home.subheading") }
      div(class: "flex justify-center gap-4 pt-4") do
        render Components::Button.new(t("home.cta_register"), href: new_registration_path)
        render Components::Button.new(t("home.cta_sign_in"), href: new_session_path, variant: :secondary)
      end
    end
  end
end
