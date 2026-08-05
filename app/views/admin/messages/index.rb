# frozen_string_literal: true

class Views::Admin::Messages::Index < Views::Admin::Base
  def initialize(messages:)
    @messages = messages
  end

  def page_title = t("admin.messages.title")

  def page_content
    div(class: "max-w-5xl mx-auto") do
      render Components::Heading.new(t("admin.messages.heading"), level: 1, classes: "mb-6")

      if @messages.empty?
        p(class: "text-(--color-ink-muted)") { t("admin.messages.empty") }
      else
        div(class: "overflow-x-auto rounded-(--radius-md) border border-(--color-border)") do
          table(class: "min-w-full divide-y divide-(--color-border) text-sm") do
            thead(class: "bg-(--color-surface)") do
              tr do
                th(class: th_classes) { t("admin.messages.columns.sender") }
                th(class: th_classes) { t("admin.messages.columns.subject") }
                th(class: th_classes) { t("admin.messages.columns.received") }
                th(class: th_classes) { t("admin.messages.columns.actions") }
              end
            end
            tbody(class: "divide-y divide-(--color-border)") do
              @messages.each { |message| render_row(message) }
            end
          end
        end
      end
    end
  end

  private

  def render_row(message)
    tr(class: "hover:bg-(--color-surface) transition-colors") do
      td(class: td_classes) { plain message.user.email_address }
      td(class: td_classes) { plain message.subject }
      td(class: "#{td_classes} text-(--color-ink-muted)") { plain l(message.created_at, format: :short) }
      td(class: td_classes) do
        button_to t("admin.messages.actions.delete"), admin_message_path(message),
          method: :delete,
          data: { turbo_confirm: t("admin.messages.actions.confirm_delete") },
          class: danger_button_classes
      end
    end
  end

  def danger_button_classes
    "inline-flex items-center px-3 py-1.5 text-sm font-medium rounded-(--radius-md) " \
    "text-(--color-danger) hover:bg-red-50 transition-colors"
  end
end
