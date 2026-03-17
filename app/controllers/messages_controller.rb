class MessagesController < ApplicationController
  before_action :set_chat

  def create
    @message = @chat.messages.build(message_params)
    @message.user = current_user

    if @message.save
      redirect_to chat_path(@chat), notice: 'Message sent successfully.'
    else
      redirect_to chat_path(@chat), alert: 'Failed to send message.'
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

end
