# frozen_string_literal: true

class Admin::MessagesController < Admin::BaseController
  def index
    @messages = Message.newest_first.includes(:user)
    render Views::Admin::Messages::Index.new(messages: @messages)
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    redirect_to admin_messages_path, notice: t("admin.messages.deleted")
  end
end
