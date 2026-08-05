# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/confirmation
  def confirmation
    UserMailer.confirmation(User.first!)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    UserMailer.welcome(User.first!)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/comment_notification
  def comment_notification
    UserMailer.comment_notification(Comment.first!)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/message_notification
  def message_notification
    UserMailer.message_notification(Message.first!, User.admin.first!)
  end
end
