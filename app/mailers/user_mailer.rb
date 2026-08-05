# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    @token = user.generate_token_for(:email_confirmation)
    @confirmation_url = confirm_registrations_url(token: @token, locale: user_locale)

    I18n.with_locale(user_locale) do
      mail(to: @user.email_address, subject: t("mailer.confirmation.subject"))
    end
  end

  private

  def user_locale
    # Use stored locale preference once users have locale field; default to I18n.default_locale
    I18n.default_locale
  end
end
