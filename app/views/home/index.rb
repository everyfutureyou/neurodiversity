# frozen_string_literal: true

class Views::Home::Index < Views::Base
  def page_title = t("home.title")

  def page_content
    hero_section
    features_section
    membership_section
  end

  private

  def hero_section
    section(aria_labelledby: "hero-heading", class: "py-20 text-center space-y-6 border-b border-(--color-border)") do
      p(class: "text-sm font-semibold text-(--color-brand) uppercase tracking-widest") { t("app.name") }
      render Components::Heading.new(level: 1, classes: "text-5xl font-extrabold tracking-tighter max-w-3xl mx-auto") do
        span(id: "hero-heading") { t("home.headline") }
      end
      p(class: "text-(--color-ink-muted) text-xl max-w-xl mx-auto") { t("home.subheading") }
      unless current_user&.member?
        div(class: "flex flex-wrap justify-center gap-4 pt-2") do
          render Components::Button.new(t("home.cta_register"), href: new_registration_path, size: :lg)
          render Components::Button.new(t("home.cta_sign_in"), href: new_session_path, variant: :secondary, size: :lg)
        end
      end
    end
  end

  def features_section
    section(aria_labelledby: "features-heading", class: "py-16 space-y-10") do
      render Components::Heading.new(level: 2, classes: "text-center") do
        span(id: "features-heading") { t("home.features.heading") }
      end
      div(class: "grid grid-cols-1 gap-6 sm:grid-cols-3 mt-8") do
        feature_card("home.features.adhd")
        feature_card("home.features.autism")
        feature_card("home.features.dyslexia")
      end
    end
  end

  def feature_card(key)
    article(class: "rounded-(--radius-md) border border-(--color-border) bg-(--color-surface) p-6 space-y-2") do
      render Components::Heading.new(t("#{key}.title"), level: 3)
      p(class: "text-(--color-ink-muted) text-sm") { t("#{key}.description") }
    end
  end

  def membership_section
    section(aria_labelledby: "membership-heading", class: "py-16 border-t border-(--color-border)") do
      div(class: "max-w-lg mx-auto space-y-6") do
        if current_user&.member?
          member_confirmation
        else
          membership_widget
        end
      end
    end
  end

  def member_confirmation
    div(class: "text-center space-y-4") do
      render Components::Heading.new(level: 2) do
        span(id: "membership-heading") { t("home.membership_cta.member_heading") }
      end
      p(class: "text-(--color-ink-muted)") { t("home.membership_cta.member_description") }
      render Components::Button.new(t("home.membership_cta.member_cta"), href: posts_path, size: :lg)
    end
  end

  def membership_widget
    div(class: "space-y-4") do
      render Components::Heading.new(level: 2, classes: "text-center") do
        span(id: "membership-heading") { t("home.membership_cta.heading") }
      end
      p(class: "text-(--color-ink-muted) text-center") { t("home.membership_cta.description") }
      render Components::PwywWidget.new
    end
  end
end
