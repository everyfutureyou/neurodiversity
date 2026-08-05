# frozen_string_literal: true

class Components::CommentItem < Components::Base
  def initialize(comment:)
    @comment = comment
  end

  def view_template
    article(id: "comment-#{@comment.id}", class: comment_classes) do
      header(class: "flex items-center gap-2 mb-1") do
        span(class: "text-sm font-medium text-(--color-ink)") { plain @comment.user.email_address }
        span(class: "text-xs text-(--color-ink-muted)") { plain l(@comment.created_at, format: :short) }
      end
      p(class: "text-sm text-(--color-ink) leading-relaxed") { plain @comment.body }

      if @comment.replies.any?
        div(class: "mt-3 pl-4 border-l-2 border-(--color-border) space-y-3") do
          @comment.replies.oldest_first.each do |reply|
            render Components::CommentItem.new(comment: reply)
          end
        end
      end

      if view_context.current_user&.admin?
        div(class: "mt-1") do
          button_to t("comments.delete"),
            view_context.post_comment_path(@comment.post, @comment),
            method: :delete,
            data: { turbo_confirm: t("comments.confirm_delete") },
            class: "text-xs text-(--color-danger) hover:underline bg-transparent border-none p-0 cursor-pointer"
        end
      end
    end
  end

  private

  def comment_classes
    base = "py-3"
    @comment.root? ? base : base
  end
end
