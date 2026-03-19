class ChatsController < ApplicationController
  def create
    @clothing_item = current_user.clothing_items.find(params[:clothing_item_id])
    @chat = Chat.new(title: Chat::DEFAULT_TITLE)
    @chat.clothing_item = @clothing_item
    @chat.user = current_user

    if @chat.save
      redirect_to chat_path(@chat)
    else
      @chats = @clothing_item.chats.where(user: current_user)
      render "clothing_items/show"
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end
end
