# frozen_string_literal: true

class Views::Admin::Posts::Index < Views::Admin::Base
  def initialize(posts:)
    @posts = posts
  end

  def page_title = t("admin.posts.title")

  def page_content
    div(class: "max-w-5xl mx-auto") do
      div(class: "flex items-center justify-between mb-6") do
        render Components::Heading.new(t("admin.posts.heading"), level: 1)
        render Components::Button.new(t("admin.posts.new"), href: new_admin_post_path, size: :sm)
      end

      if @posts.empty?
        p(class: "text-(--color-ink-muted)") { t("admin.posts.empty") }
      else
        div(class: "overflow-x-auto rounded-(--radius-md) border border-(--color-border)") do
          table(class: "min-w-full divide-y divide-(--color-border) text-sm") do
            thead(class: "bg-(--color-surface)") do
              tr do
                th(class: th_classes) { t("admin.posts.columns.title") }
                th(class: th_classes) { t("admin.posts.columns.slug") }
                th(class: th_classes) { t("admin.posts.columns.status") }
                th(class: th_classes) { t("admin.posts.columns.author") }
                th(class: th_classes) { t("admin.posts.columns.actions") }
              end
            end
            tbody(class: "divide-y divide-(--color-border)") do
              @posts.each { |post| render_row(post) }
            end
          end
        end
      end
    end
  end

  private

  def render_row(post)
    tr(class: "hover:bg-(--color-surface) transition-colors") do
      td(class: td_classes) do
        plain post.localized_title(:en).presence || post.localized_title(:de)
      end
      td(class: "#{td_classes} font-mono text-xs text-(--color-ink-muted)") { plain post.slug }
      td(class: td_classes) { render_status_badge(post) }
      td(class: "#{td_classes} text-(--color-ink-muted)") { plain post.author_email_address }
      td(class: td_classes) { render_actions(post) }
    end
  end

  def render_status_badge(post)
    if post.published?
      span(class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium bg-green-100 text-green-800") do
        t("admin.posts.status.published")
      end
    else
      span(class: "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium bg-(--color-surface) text-(--color-ink-muted) border border-(--color-border)") do
        t("admin.posts.status.draft")
      end
    end
  end

  def render_actions(post)
    div(class: "flex items-center gap-2") do
      render Components::Button.new(t("admin.posts.actions.edit"),
        href: edit_admin_post_path(post), variant: :ghost, size: :sm)

      if post.published?
        button_to t("admin.posts.actions.unpublish"), unpublish_admin_post_path(post),
          method: :patch,
          class: ghost_button_classes
      else
        button_to t("admin.posts.actions.publish"), publish_admin_post_path(post),
          method: :patch,
          class: ghost_button_classes
      end

      button_to t("admin.posts.actions.delete"), admin_post_path(post),
        method: :delete,
        data: { turbo_confirm: t("admin.posts.actions.confirm_delete") },
        class: danger_button_classes
    end
  end

  def ghost_button_classes
    "inline-flex items-center px-3 py-1.5 text-sm font-medium rounded-(--radius-md) " \
    "hover:bg-(--color-surface) text-(--color-ink-muted) hover:text-(--color-ink) transition-colors"
  end

  def danger_button_classes
    "inline-flex items-center px-3 py-1.5 text-sm font-medium rounded-(--radius-md) " \
    "text-(--color-danger) hover:bg-red-50 transition-colors"
  end
end
