# frozen_string_literal: true

class Views::Registrations::New < Views::Base
  def initialize(user: nil)
    @user = user
  end

  def page_title = t("registrations.new.title")

  def page_content
    div(class: "max-w-md mx-auto") do
      render Components::Heading.new(t("registrations.new.heading"), level: 1, classes: "text-center mb-8")

      div(class: "bg-(--color-surface) border border-(--color-border) rounded-(--radius-xl) p-8 shadow-(--shadow-sm)") do
        form_with(model: @user, url: registrations_path, method: :post) do |f|
          div(class: "space-y-4") do
            render Components::FormField.new(
              label: t("fields.email"),
              for_id: "user_email_address",
              error: @user&.errors[:email_address]&.first
            ) do
              f.email_field :email_address, id: "user_email_address",
                            required: true, autofocus: true,
                            autocomplete: "email",
                            class: input_classes
            end
            render Components::FormField.new(
              label: t("fields.password"),
              for_id: "user_password",
              error: @user&.errors[:password]&.first
            ) do
              f.password_field :password, id: "user_password",
                               required: true,
                               autocomplete: "new-password",
                               minlength: 12,
                               class: input_classes
            end
            render Components::FormField.new(
              label: t("fields.password_confirmation"),
              for_id: "user_password_confirmation"
            ) do
              f.password_field :password_confirmation, id: "user_password_confirmation",
                               required: true,
                               autocomplete: "new-password",
                               class: input_classes
            end
            render Components::Button.new(t("registrations.new.submit"), type: "submit", variant: :primary,
                                              classes: "w-full")
          end
        end

        p(class: "mt-4 text-center text-sm text-(--color-ink-muted)") do
          plain t("registrations.new.have_account")
          plain " "
          link_to t("registrations.new.sign_in_link"), new_session_path,
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
