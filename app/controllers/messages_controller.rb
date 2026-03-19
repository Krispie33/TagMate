class MessagesController < ApplicationController
  # prompt = "Could you analyse the error message on the screenshot and help me solve it?"
  # prompt = <<-PROMPT
  # You are an experienced chef, specialised in French gastronomy.
  # I am a beginner cook, looking to learn simple recipes.
  # Guide me into making a classic French oeuf mayo.
  # Provide step-by-step instructions in bullet points, using Markdown.
  # PROMPT
  SYSTEM_PROMPT = "You are a Teaching Assistant.\n\nI am a student at the Le Wagon AI Software Development
  Bootcamp, learning how to code.\n\nHelp me break down my problem into small, actionable steps, without giving
  away solutions.\n\nAnswer concisely in Markdown."
  def create
    @chat = current_user.chats.find(params[:chat_id])
    @challenge = @chat.challenge

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save # First, we store the user message
      if @message.file.attached? # Then we ask the LLM
        process_file(@message.file) # send question w/ file to the appropriate model
      else
        send_question # send question to the model
      end
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
    @response = @ruby_llm_chat.ask(@message.content, with: with) # prompt
  end
end
