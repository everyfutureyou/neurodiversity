# frozen_string_literal: true

class Views::Sessions::New < Views::Base
  def initialize(email_address: nil)
    @email_address = email_address
  end

  def page_title = t("sessions.new.title")

  def page_content
    div(class: "max-w-md mx-auto") do
      render Components::Heading.new(t("sessions.new.heading"), level: 1, classes: "text-center mb-8")

      div(class: "bg-(--color-surface) border border-(--color-border) rounded-(--radius-xl) p-8 shadow-(--shadow-sm)") do
        form_with(url: session_path, method: :post) do |f|
          div(class: "space-y-4") do
            render Components::FormField.new(label: t("fields.email"), for_id: "email_address") do
              f.email_field :email_address, id: "email_address",
                            value: @email_address,
                            required: true, autofocus: true,
                            autocomplete: "email",
                            class: input_classes
            end
            render Components::FormField.new(label: t("fields.password"), for_id: "password") do
              f.password_field :password, id: "password",
                               required: true,
                               autocomplete: "current-password",
                               class: input_classes
            end
            div(class: "flex items-center justify-between text-sm") do
              label(class: "flex items-center gap-2 cursor-pointer") do
                f.check_box :remember_me, class: "rounded border-(--color-border)"
                span(class: "text-(--color-ink-muted)") { t("sessions.new.remember_me") }
              end
              link_to t("sessions.new.forgot_password"), new_password_path,
                      class: "text-(--color-brand) hover:underline"
            end
            render Components::Button.new(t("sessions.new.submit"), type: "submit", variant: :primary,
                                              classes: "w-full")
          end
        end

        p(class: "mt-4 text-center text-sm text-(--color-ink-muted)") do
          plain t("sessions.new.no_account")
          plain " "
          link_to t("sessions.new.register_link"), new_registration_path,
                  class: "text-(--color-brand) hover:underline"
        end
      end
    end
  end

  private

  def input_classes
    "w-full rounded-(--radius-md) border border-(--color-border) bg-(--color-canvas) " \
      "px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-(--color-brand)"
  end
end
