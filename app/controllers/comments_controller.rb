# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :require_confirmed!
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      UserMailer.comment_notification(@comment).deliver_later if notify_post_author?
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to post_path(@post.slug), notice: t("comments.created") }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :create_error, status: :unprocessable_entity }
        format.html { redirect_to post_path(@post.slug), alert: @comment.errors.full_messages.first }
      end
    end
  end

  def destroy
    require_admin!
    return if performed?

    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_path(@post.slug), notice: t("comments.deleted")
  end

  private

  def set_post
    @post = Post.published.find_by!(slug: params[:post_slug])
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError, "Not Found"
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def notify_post_author?
    @post.author != current_user
  end

  def require_confirmed!
    unless current_user&.confirmed?
      redirect_to root_path, alert: t("authorization.confirmation_required")
    end
  end
end
