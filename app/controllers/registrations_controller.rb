# frozen_string_literal: true

class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    render Views::Registrations::New.new(user: User.new)
  end

  def create
    @user = User.new(registration_params)
    @user.locale = I18n.locale.to_s
    if @user.save
      UserMailer.confirmation(@user).deliver_later
      render Views::Registrations::Confirm.new
    else
      render Views::Registrations::New.new(user: @user), status: :unprocessable_entity
    end
  end

  def confirm
    user = User.find_by_token_for(:email_confirmation, params[:token])

    if user
      user.update!(confirmed_at: Time.current)
      UserMailer.welcome(user).deliver_later
      start_new_session_for(user)
      redirect_to root_path, notice: t("registrations.confirmed")
    else
      redirect_to new_registration_path, alert: t("registrations.invalid_token")
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
