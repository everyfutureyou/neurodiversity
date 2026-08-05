class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    locale = user.locale.presence || I18n.default_locale.to_s

    I18n.with_locale(locale) do
      mail subject: t("mailer.reset.subject"), to: user.email_address
    end
  end
end
