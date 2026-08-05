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
    end
  end

  private

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
