# frozen_string_literal: true

class Views::Posts::Show < Views::Base
  def initialize(post:)
    @post = post
  end

  def page_title = @post.localized_title

  def page_meta
    description = @post.localized_body.first(160)
    {
      description: description,
      og: {
        title: @post.localized_title,
        description: description,
        type: "article",
        url: view_context.request.original_url
      },
      json_ld: article_json_ld
    }
  end

  def page_content
    article(class: "max-w-3xl mx-auto") do
      header(class: "mb-8") do
        render Components::Heading.new(@post.localized_title, level: 1, classes: "mb-3")
        div(class: "flex items-center gap-3 text-(--color-ink-muted) text-sm") do
          span { t("posts.show.by", author: @post.author_email_address) }
          span { "·" }
          span { l(@post.published_at, format: :short) }
        end
      end

      div(class: "prose prose-neutral max-w-none") do
        plain @post.localized_body
      end

      div(class: "mt-10 pt-6 border-t border-(--color-border)") do
        a(href: posts_path, class: "text-(--color-brand) hover:underline text-sm font-medium") do
          t("posts.show.back")
        end
      end

      render_comments_section
    end
  end

  private

  def render_comments_section
    section(class: "max-w-3xl mx-auto mt-10 pt-8 border-t border-(--color-border)",
            aria: { labelledby: "comments-heading" }) do
      h2(id: "comments-heading", class: "text-lg font-semibold text-(--color-ink) mb-4") do
        t("comments.heading")
      end

      div(id: "post-#{@post.id}-comments", class: "space-y-3 mb-6") do
        roots = @post.comments.roots.includes(:user, replies: :user).oldest_first
        if roots.empty?
          p(id: "comments-empty", class: "text-sm text-(--color-ink-muted) italic") do
            t("comments.none")
          end
        else
          roots.each { |comment| render Components::CommentItem.new(comment: comment) }
        end
      end

      render Components::CommentForm.new(post: @post)
    end
  end

  def article_json_ld
    {
      "@context" => "https://schema.org",
      "@type" => "Article",
      "headline" => @post.localized_title,
      "datePublished" => @post.published_at.iso8601,
      "author" => { "@type" => "Person", "email" => @post.author_email_address },
      "url" => view_context.request.original_url
    }
  end
end
