# frozen_string_literal: true

class MessagesController < ApplicationController
  def new
    @message = Message.new
    render Views::Messages::New.new(message: @message)
  end

  def create
    @message = current_user.messages.build(message_params)

    if @message.save
      User.admin.each { |admin| UserMailer.message_notification(@message, admin).deliver_later }
      redirect_to root_path, notice: t("messages.sent")
    else
      render Views::Messages::New.new(message: @message), status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:subject, :body)
  end
end
