# frozen_string_literal: true

class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[edit update destroy publish unpublish]

  def index
    @posts = Post.includes(:author).order(created_at: :desc)
    render Views::Admin::Posts::Index.new(posts: @posts)
  end

  def new
    @post = Post.new
    render Views::Admin::Posts::Form.new(post: @post)
  end

  def create
    @post = Post.new(post_params)
    @post.author = current_user

    if @post.save
      redirect_to admin_posts_path, notice: t("admin.posts.created")
    else
      render Views::Admin::Posts::Form.new(post: @post), status: :unprocessable_entity
    end
  end

  def edit
    render Views::Admin::Posts::Form.new(post: @post)
  end

  def update
    if @post.update(post_params)
      redirect_to admin_posts_path, notice: t("admin.posts.updated")
    else
      render Views::Admin::Posts::Form.new(post: @post), status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    redirect_to admin_posts_path, notice: t("admin.posts.deleted")
  end

  def publish
    @post.publish!
    redirect_to admin_posts_path, notice: t("admin.posts.published")
  end

  def unpublish
    @post.unpublish!
    redirect_to admin_posts_path, notice: t("admin.posts.unpublished")
  end

  private

  def set_post
    @post = Post.find_by!(slug: params[:slug])
  end

  def post_params
    params.require(:post).permit(:slug, title: %i[en de], body: %i[en de]).tap do |p|
      p[:title]&.compact_blank!
      p[:body]&.compact_blank!
    end
  end
end
