# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  def index
    @users = User.order(:email_address)
    render Views::Admin::Users::Index.new(users: @users)
  end
end
