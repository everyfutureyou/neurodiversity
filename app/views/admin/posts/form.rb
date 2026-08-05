# frozen_string_literal: true

class Views::Admin::Posts::Form < Views::Base
  def initialize(post:)
    @post = post
  end

  def page_title
    @post.new_record? ? t("admin.posts.new") : t("admin.posts.edit")
  end

  def page_content
    div(class: "max-w-3xl mx-auto") do
      render Components::Heading.new(page_title, level: 1, classes: "mb-6")

      div(class: "bg-(--color-surface) border border-(--color-border) rounded-(--radius-xl) p-8") do
        url = @post.new_record? ? admin_posts_path : admin_post_path(@post)
        method = @post.new_record? ? :post : :patch

        form_with(model: [ :admin, @post ], url: url, method: method) do |f|
          div(class: "space-y-6") do
            render Components::FormField.new(
              label: t("admin.posts.fields.slug"),
              for_id: "post_slug",
              error: @post.errors[:slug]&.first
            ) do
              f.text_field :slug, id: "post_slug",
                           class: input_classes,
                           placeholder: "my-post-slug"
            end

            render Components::FormField.new(
              label: t("admin.posts.fields.title_en"),
              for_id: "post_title_en"
            ) do
              tag.input(
                type: "text",
                name: "post[title][en]",
                id: "post_title_en",
                value: @post.title["en"],
                class: input_classes
              )
            end

            render Components::FormField.new(
              label: t("admin.posts.fields.title_de"),
              for_id: "post_title_de"
            ) do
              tag.input(
                type: "text",
                name: "post[title][de]",
                id: "post_title_de",
                value: @post.title["de"],
                class: input_classes
              )
            end

            render Components::FormField.new(
              label: t("admin.posts.fields.body_en"),
              for_id: "post_body_en"
            ) do
              tag.textarea(
                name: "post[body][en]",
                id: "post_body_en",
                rows: 8,
                class: input_classes
              ) { plain @post.body["en"] }
            end

            render Components::FormField.new(
              label: t("admin.posts.fields.body_de"),
              for_id: "post_body_de"
            ) do
              tag.textarea(
                name: "post[body][de]",
                id: "post_body_de",
                rows: 8,
                class: input_classes
              ) { plain @post.body["de"] }
            end

            div(class: "flex items-center gap-3 pt-2") do
              render Components::Button.new(t("admin.posts.fields.save"), type: "submit")
              render Components::Button.new(t("admin.posts.fields.cancel"),
                href: admin_posts_path, variant: :secondary)
            end
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
