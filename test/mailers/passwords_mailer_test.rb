# frozen_string_literal: true

require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset renders to recipient" do
    user = users(:one)
    mail = PasswordsMailer.reset(user)

    assert_equal [ user.email_address ], mail.to
  end

  test "reset subject uses i18n key" do
    user = users(:one)
    mail = PasswordsMailer.reset(user)

    assert_equal I18n.t("mailer.reset.subject", locale: user.locale.to_sym), mail.subject
  end

  test "reset renders DE subject for DE user" do
    user = users(:one)
    user.locale = "de"

    mail = PasswordsMailer.reset(user)

    assert_equal I18n.t("mailer.reset.subject", locale: :de), mail.subject
  end

  test "reset html body contains reset link" do
    user = users(:one)
    mail = PasswordsMailer.reset(user)

    assert_match "/passwords/", mail.html_part.body.encoded
  end
end
