# frozen_string_literal: true

class Views::Admin::Users::Index < Views::Admin::Base
  def initialize(users:)
    @users = users
  end

  def page_title = t("admin.users.title")

  def page_content
    div(class: "max-w-5xl mx-auto") do
      render Components::Heading.new(t("admin.users.heading"), level: 1, classes: "mb-6")

      div(class: "overflow-x-auto rounded-(--radius-md) border border-(--color-border)") do
        table(class: "min-w-full divide-y divide-(--color-border) text-sm") do
          thead(class: "bg-(--color-surface)") do
            tr do
              th(class: th_classes) { t("admin.users.columns.email") }
              th(class: th_classes) { t("admin.users.columns.role") }
              th(class: th_classes) { t("admin.users.columns.confirmed") }
              th(class: th_classes) { t("admin.users.columns.joined") }
            end
          end
          tbody(class: "divide-y divide-(--color-border)") do
            @users.each { |user| render_row(user) }
          end
        end
      end
    end
  end

  private

  def render_row(user)
    tr(class: "hover:bg-(--color-surface) transition-colors") do
      td(class: td_classes) { plain user.email_address }
      td(class: td_classes) { render_role_badge(user) }
      td(class: td_classes) do
        if user.confirmed?
          span(class: "text-green-600") { t("admin.users.confirmed") }
        else
          span(class: "text-(--color-ink-muted)") { t("admin.users.unconfirmed") }
        end
      end
      td(class: "#{td_classes} text-(--color-ink-muted)") { plain l(user.created_at, format: :short) }
    end
  end

  def render_role_badge(user)
    classes = if user.admin?
                "bg-purple-100 text-purple-800"
              elsif user.member?
                "bg-blue-100 text-blue-800"
              else
                "bg-(--color-surface) text-(--color-ink-muted) border border-(--color-border)"
              end
    span(class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium #{classes}") do
      t("admin.users.roles.#{user.role}")
    end
  end
end
