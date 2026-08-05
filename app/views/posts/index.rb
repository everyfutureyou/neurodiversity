# frozen_string_literal: true

class Views::Posts::Index < Views::Base
  def initialize(posts:)
    @posts = posts
  end

  def page_title = t("posts.index.title")

  def page_content
    div(class: "max-w-3xl mx-auto space-y-8") do
      render Components::Heading.new(t("posts.index.heading"), level: 1)

      if @posts.empty?
        p(class: "text-(--color-ink-muted)") { t("posts.index.empty") }
      else
        div(class: "space-y-6") do
          @posts.each { |post| render_post_card(post) }
        end
      end
    end
  end

  private

  def render_post_card(post)
    article(class: "border-b border-(--color-border) pb-6 last:border-0") do
      render Components::Heading.new(
        post.localized_title,
        level: 2,
        classes: "mb-2"
      )
      p(class: "text-(--color-ink-muted) text-sm mb-3") do
        plain t("posts.index.published_at", date: l(post.published_at, format: :short))
        plain " · "
        plain post.author_email_address
      end
      a(href: post_path(post), class: "text-(--color-brand) hover:underline text-sm font-medium") do
        t("posts.index.read_more")
      end
    end
  end
end
