# frozen_string_literal: true

class Views::Passwords::New < Views::Base
  def page_title = t("passwords.new.title")

  def page_content
    div(class: "max-w-md mx-auto") do
      render Components::Heading.new(t("passwords.new.heading"), level: 1, classes: "text-center mb-8")
      p(class: "text-center text-(--color-ink-muted) mb-6 text-sm") { t("passwords.new.instructions") }

      div(class: "bg-(--color-surface) border border-(--color-border) rounded-(--radius-xl) p-8 shadow-(--shadow-sm)") do
        form_with(url: passwords_path, method: :post) do |f|
          div(class: "space-y-4") do
            render Components::FormField.new(label: t("fields.email"), for_id: "email_address") do
              f.email_field :email_address, id: "email_address",
                            required: true, autofocus: true,
                            autocomplete: "email",
                            class: input_classes
            end
            render Components::Button.new(t("passwords.new.submit"), type: "submit", classes: "w-full")
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
