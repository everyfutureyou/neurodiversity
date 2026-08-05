# frozen_string_literal: true

class Views::Messages::New < Views::Base
  def initialize(message:)
    @message = message
  end

  def page_title = t("messages.new.title")

  def page_content
    div(class: "max-w-xl mx-auto") do
      render Components::Heading.new(t("messages.new.heading"), level: 1, classes: "mb-2")
      p(class: "text-(--color-ink-muted) mb-6") { t("messages.new.description") }

      errors_for(@message)

      form_with(model: @message, url: messages_path, method: :post) do |f|
        div(class: "space-y-4") do
          render Components::FormField.new(
            label: t("messages.new.subject_label"),
            for_id: "message_subject",
            error: @message.errors[:subject].first
          ) do
            f.text_field :subject,
              id: "message_subject",
              class: input_classes,
              autofocus: true,
              required: true
          end

          render Components::FormField.new(
            label: t("messages.new.body_label"),
            for_id: "message_body",
            error: @message.errors[:body].first
          ) do
            f.text_area :body,
              id: "message_body",
              rows: 5,
              class: "#{input_classes} resize-y",
              required: true
          end

          render Components::Button.new(t("messages.new.submit"), type: "submit")
        end
      end
    end
  end

  private

  def input_classes
    "w-full rounded-(--radius-md) border border-(--color-border) bg-(--color-surface) " \
    "px-3 py-2 text-sm text-(--color-ink) focus:outline-none focus:ring-2 " \
    "focus:ring-(--color-brand) focus:ring-offset-2"
  end

  def errors_for(record)
    return unless record.errors.any?

    div(class: "mb-4 rounded-(--radius-md) border border-(--color-danger) bg-red-50 p-3") do
      ul(class: "list-disc list-inside text-sm text-(--color-danger)") do
        record.errors.full_messages.each do |msg|
          li { plain msg }
        end
      end
    end
  end
end
