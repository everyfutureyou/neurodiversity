# frozen_string_literal: true

class Components::CommentForm < Components::Base
  def initialize(post:, parent_id: nil)
    @post = post
    @parent_id = parent_id
  end

  def view_template
    if current_user&.confirmed?
      render_form
    elsif current_user
      p(class: "text-sm text-(--color-ink-muted) italic") { t("comments.confirm_to_comment") }
    else
      render_sign_in_prompt
    end
  end

  private

  def render_form
    form_with(
      url: view_context.post_comments_path(@post),
      method: :post,
      data: { turbo: true }
    ) do |f|
      if @parent_id
        f.hidden_field :parent_id, value: @parent_id
      end

      div(class: "space-y-2") do
        render Components::FormField.new(label: t("comments.body_label"), for_id: "comment_body") do
          f.text_area :body,
            id: "comment_body",
            rows: 3,
            placeholder: t("comments.body_placeholder"),
            required: true,
            class: "w-full rounded-(--radius-md) border border-(--color-border) bg-(--color-surface) " \
                   "px-3 py-2 text-sm text-(--color-ink) focus:outline-none focus:ring-2 " \
                   "focus:ring-(--color-brand) focus:ring-offset-2 resize-y"
        end

        div(class: "flex justify-end") do
          render Components::Button.new(t("comments.submit"), type: "submit", size: :sm)
        end
      end
    end
  end

  def render_sign_in_prompt
    div(class: "rounded-(--radius-md) border border-(--color-border) bg-(--color-surface) p-4 text-center") do
      p(class: "text-sm text-(--color-ink-muted) mb-3") { t("comments.sign_in_to_comment") }
      render Components::Button.new(t("comments.sign_in_cta"), href: view_context.new_session_path, variant: :secondary, size: :sm)
    end
  end
end
