# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def confirmation(user)
    @user = user
    @token = user.generate_token_for(:email_confirmation)
    @confirmation_url = confirm_registrations_url(token: @token, locale: user_locale(user))

    I18n.with_locale(user_locale(user)) do
      mail(to: @user.email_address, subject: t("mailer.confirmation.subject"))
    end
  end

  def welcome(user)
    @user = user
    @blog_url = posts_url(locale: user_locale(user))

    I18n.with_locale(user_locale(user)) do
      mail(to: @user.email_address, subject: t("mailer.welcome.subject"))
    end
  end

  def comment_notification(comment)
    @comment  = comment
    @post     = comment.post
    @author   = @post.author
    @post_url = post_url(@post.slug, locale: user_locale(@author))

    I18n.with_locale(user_locale(@author)) do
      mail(to: @author.email_address, subject: t("mailer.comment_notification.subject"))
    end
  end

  def message_notification(message, admin)
    @message      = message
    @admin        = admin
    @messages_url = admin_messages_url(locale: user_locale(admin))

    I18n.with_locale(user_locale(admin)) do
      mail(to: admin.email_address, subject: t("mailer.message_notification.subject"))
    end
  end

  private

  def user_locale(user)
    user.locale.presence || I18n.default_locale.to_s
  end
end
