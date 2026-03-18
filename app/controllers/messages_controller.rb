class MessagesController < ApplicationController
  # prompt = "Could you analyse the error message on the screenshot and help me solve it?"
  def create
    # [...]

    if @message.save
      if @message.file.attached?
        process_file(@message.file) # send question w/ file to the appropriate model
      else
        send_question # send question to the model
      end
      @chat.messages.create(role: "assistant", content: @response.content)
      @chat.generate_title_from_first_message
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :file)
  end

  def build_conversation_history
    @chat.messages.each do |message|
      @ruby_llm_chat.add_message(message)
    end
  end

  def process_file(file)
    if file.image?
      send_question(model: "gpt-4o", with: { image: @message.file.url }) # vision-capable model
    end
  end

  def send_question(model: "gpt-4.1-nano", with: {})
    @ruby_llm_chat = RubyLLM.chat(model: model)
    build_conversation_history
    @ruby_llm_chat.with_instructions(instructions)
    @response = @ruby_llm_chat.ask(@message.content, with: with)
  end
end
