class ChatsController < ApplicationController
  def create
    @clothing_item = current_user.clothing_items.find(params[:clothing_item_id])
    @chat = Chat.new(user: current_user, drawer: @clothing_item.drawer)

    if @chat.save
      redirect_to chat_path(@chat)
    else
      render "clothing_items/show", status: :unprocessable_entity
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @message = Message.new
  end
end
