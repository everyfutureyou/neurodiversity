# frozen_string_literal: true

class Views::Passwords::Edit < Views::Base
  def page_title = t("passwords.edit.title")

  def page_content
    div(class: "max-w-md mx-auto") do
      render Components::Heading.new(t("passwords.edit.heading"), level: 1, classes: "text-center mb-8")

      div(class: "bg-(--color-surface) border border-(--color-border) rounded-(--radius-xl) p-8 shadow-(--shadow-sm)") do
        form_with(url: password_path(view_context.params[:token]), method: :patch) do |f|
          div(class: "space-y-4") do
            render Components::FormField.new(label: t("fields.password"), for_id: "password") do
              f.password_field :password, id: "password",
                               required: true,
                               autocomplete: "new-password",
                               minlength: 12,
                               class: input_classes
            end
            render Components::FormField.new(label: t("fields.password_confirmation"),
                                                 for_id: "password_confirmation") do
              f.password_field :password_confirmation, id: "password_confirmation",
                               required: true,
                               autocomplete: "new-password",
                               class: input_classes
            end
            render Components::Button.new(t("passwords.edit.submit"), type: "submit", classes: "w-full")
          end
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
