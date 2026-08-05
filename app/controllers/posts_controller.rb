# frozen_string_literal: true

class PostsController < ApplicationController
  allow_unauthenticated_access

  def index
    @posts = Post.published.in_locale(I18n.locale).newest_first
    render Views::Posts::Index.new(posts: @posts)
  end

  def show
    @post = Post.published.find_by(slug: params[:slug])
    raise ActionController::RoutingError, "Not Found" unless @post

    render Views::Posts::Show.new(post: @post)
  end
end
