# frozen_string_literal: true

class SitemapController < ApplicationController
  allow_unauthenticated_access
  layout false

  def show
    @posts = Post.published.newest_first
    respond_to do |format|
      format.xml { render :show }
    end
  end
end
