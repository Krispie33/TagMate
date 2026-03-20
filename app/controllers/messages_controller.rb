class MessagesController < ApplicationController
  SYSTEM_PROMPT = <<~PROMPT
    You are a friendly Washing Assistant helping a young adult do their laundry for the first time.
    Help them understand care labels, sort clothes into drawers, and wash each load correctly.
    Answer concisely in Markdown.
  PROMPT

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params.merge(chat: @chat, role: "user"))

    if @message.save
      send_question
      @chat.messages.create(role: "assistant", content: @response.content)
      @chat.generate_title_from_first_message
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :file)
  end

  def build_conversation_history
    @chat.messages.each { |msg| @ruby_llm_chat.add_message(msg) }
  end

  def send_question
    @ruby_llm_chat = RubyLLM.chat(model: "gpt-4.1-nano")
    build_conversation_history
    @ruby_llm_chat.with_instructions(SYSTEM_PROMPT)
    @response = @ruby_llm_chat.ask(@message.content)
  end
end
