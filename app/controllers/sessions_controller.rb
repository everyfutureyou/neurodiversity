class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: t("sessions.rate_limited") }

  def new
    render Views::Sessions::New.new(email_address: params[:email_address])
  end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user.nil?
      redirect_to new_session_path, alert: t("sessions.invalid_credentials")
    elsif !user.confirmed?
      redirect_to new_session_path, alert: t("sessions.unconfirmed")
    else
      start_new_session_for user
      redirect_to after_authentication_url
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end
end
