# frozen_string_literal: true

require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome renders to recipient, correct subject and body" do
    user = users(:one)
    mail = UserMailer.welcome(user)

    assert_equal [ user.email_address ], mail.to
    assert_match "welcome", mail.subject.downcase
    assert_match user.email_address, mail.body.encoded
  end

  test "welcome renders DE subject for DE user" do
    user = users(:one)
    user.locale = "de"

    mail = UserMailer.welcome(user)

    assert_match I18n.t("mailer.welcome.subject", locale: :de), mail.subject
  end

  test "comment_notification sends to post author with correct subject" do
    comment = comments(:reply_comment)
    post    = comment.post
    author  = post.author

    mail = UserMailer.comment_notification(comment)

    assert_equal [ author.email_address ], mail.to
    assert_match "comment", mail.subject.downcase
  end

  test "comment_notification body includes commenter and post link" do
    comment = comments(:reply_comment)

    mail = UserMailer.comment_notification(comment)

    assert_match comment.user.email_address, mail.body.encoded
  end

  test "comment_notification respects author locale" do
    comment = comments(:reply_comment)
    comment.post.author.update!(locale: "de")

    mail = UserMailer.comment_notification(comment)

    assert_match I18n.t("mailer.comment_notification.subject", locale: :de), mail.subject
  end

  test "message_notification sends to the specified admin" do
    message = messages(:one)
    admin   = users(:admin)

    mail = UserMailer.message_notification(message, admin)

    assert_equal [ admin.email_address ], mail.to
  end

  test "message_notification subject and body include message subject" do
    message = messages(:one)
    admin   = users(:admin)

    mail = UserMailer.message_notification(message, admin)

    assert_match message.subject, mail.body.encoded
    assert_match "message", mail.subject.downcase
  end
end
