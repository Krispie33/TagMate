class ChatsController < ApplicationController
  def create
    @drawer = current_user.drawers.find(params[:drawer_id])

    @chat = Chat.new(user: current_user, drawer: @drawer)
    @chat.title = @drawer.name
    if @chat.save!
      redirect_to chat_path(@chat)
    else
      redirect_to drawer_path(@drawer), alert: "Could not start a chat. Please try again."
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end
end
