# rubocop:disable Metrics/ClassLength
class MessagesController < ApplicationController
  TAG_ANALYSIS_SYSTEM_PROMPT = <<~PROMPT
    You are a laundry care label expert. Analyse the clothing care label symbols and text in the image.

    Return ONLY a valid JSON object with these exact fields — no markdown, no explanation, just JSON:
    {
      "wash_temp": <integer in Celsius, e.g. 30, 40, 60 — use null for cold/hand wash or if unspecified>,
      "bleach_allowed": <boolean — true only if a bleach symbol without a cross is shown>,
      "tumble_dry": <boolean — true if tumble drying is permitted>,
      "iron_allowed": <boolean — true if ironing is permitted>,
      "dry_clean": <boolean — true if a dry-clean circle symbol is shown>,
      "care_summary": <string — one concise sentence describing all care instructions>
    }
  PROMPT

  DRAWER_INSTRUCTIONS_SYSTEM_PROMPT = <<~PROMPT
    You are a laundry assistant helping a young adult do their first laundry.
    Write clear, actionable washing instructions for a drawer of clothes that all share the same care settings.
    Use simple language, bullet points, and Markdown. Keep it under 150 words.
  PROMPT

  SYSTEM_PROMPT = <<~PROMPT
    You are a friendly Washing Assistant helping a young adult do their laundry for the first time.
    Help them understand care labels, sort clothes into drawers, and wash each load correctly.
    Answer concisely in Markdown.
  PROMPT

  def new
    @chat = find_or_create_scan_chat
    @message = Message.new
  end

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @message = Message.new(message_params.merge(chat: @chat, role: "user"))
    @message.content = "Scan care label" if @message.content.blank?

    if @message.save
      generate_assistant_response
      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def find_or_create_scan_chat
    profile = current_user.profiles.first
    drawer = profile&.drawers&.first || profile&.drawers&.create!(name: "Scanned Items")
    current_user.chats.find_or_create_by!(title: "Tag Scans") do |c|
      c.drawer = drawer
    end
  end

  def generate_assistant_response
    if @message.file.attached? && @message.file.image?
      process_tag_image(@message.file)
    else
      send_question
    end
    @chat.messages.create(role: "assistant", content: @response.content)
    @chat.generate_title_from_first_message
  end

  def message_params
    params.require(:message).permit(:content, :file)
  end

  def build_conversation_history
    @chat.messages.each { |msg| @ruby_llm_chat.add_message(msg) }
  end

  def send_question(model: "gpt-4.1-nano", with: {})
    @ruby_llm_chat = RubyLLM.chat(model: model)
    build_conversation_history
    @ruby_llm_chat.with_instructions(SYSTEM_PROMPT)
    @response = @ruby_llm_chat.ask(@message.content, with: with)
  end

  def process_tag_image(file)
    care_data = extract_care_data(file)
    drawer = find_or_create_drawer_for(care_data)
    create_clothing_item(care_data, drawer)
    update_drawer_instructions(drawer)
    confirm_tag_analysis(care_data, drawer)
  rescue JSON::ParserError
    send_question(model: "gpt-4o", with: { image: file.url })
  end

  def extract_care_data(file)
    llm = RubyLLM.chat(model: "gpt-4o")
    llm.with_instructions(TAG_ANALYSIS_SYSTEM_PROMPT)
    raw = llm.ask(
      "Analyse this clothing care label and return the JSON object described in the instructions.",
      with: { image: file.url }
    )
    JSON.parse(raw.content)
  end

  def create_clothing_item(care_data, drawer)
    item = ClothingItem.new(care_item_attrs(care_data, drawer))
    item.user_id = current_user.id
    item.save(validate: false) # tag/item images are uploaded separately via ClothingItemsController
  end

  def care_item_attrs(care_data, drawer)
    {
      wash_temp: care_data["wash_temp"],
      bleach_allowed: care_data["bleach_allowed"] || false,
      tumble_dry: care_data["tumble_dry"] || false,
      iron_allowed: care_data["iron_allowed"] || false,
      dry_clean: care_data["dry_clean"] || false,
      care_summary: care_data["care_summary"],
      ai_raw_response: care_data,
      drawer: drawer
    }
  end

  def confirm_tag_analysis(care_data, drawer)
    llm = RubyLLM.chat(model: "gpt-4.1-nano")
    llm.with_instructions(SYSTEM_PROMPT)
    @response = llm.ask(
      "I scanned a clothing tag and found: #{care_data['care_summary']}. " \
      "I've placed the item in the '#{drawer.name}' drawer. " \
      "Please confirm this and give me the 2–3 most important washing tips for this item."
    )
  end

  # Finds a drawer with matching wash settings, or creates a new one.
  def find_or_create_drawer_for(care_data)
    wash_temp = care_data["wash_temp"]
    dry_clean = care_data["dry_clean"]

    profile = current_user.profiles.first
    return build_and_save_drawer(care_data, profile) unless profile

    # Look for an existing drawer that already has items with the same key settings
    matching = profile.drawers
                      .joins(:clothing_items)
                      .where(clothing_items: { wash_temp: wash_temp, dry_clean: dry_clean })
                      .first

    matching || build_and_save_drawer(care_data, profile)
  end

  def build_and_save_drawer(care_data, profile)
    wash_temp = care_data["wash_temp"]
    dry_clean = care_data["dry_clean"]

    name = if dry_clean
             "Dry Clean Only"
           elsif wash_temp.nil?
             "Cold / Hand Wash"
           else
             "#{wash_temp}°C Wash"
           end

    drawer = profile.drawers.new(name: name)
    drawer.save(validate: false)
    drawer
  end

  # Asks the LLM to write washing instructions for all items in the drawer
  # and persists the result in drawers.instructions.
  def update_drawer_instructions(drawer)
    items = drawer.clothing_items.reload
    return if items.empty?

    sample = items.first
    settings = [
      "Wash at #{sample.wash_temp || 'cold'}°C",
      "Bleach: #{sample.bleach_allowed ? 'allowed' : 'not allowed'}",
      "Tumble dry: #{sample.tumble_dry ? 'yes' : 'no'}",
      "Iron: #{sample.iron_allowed ? 'yes' : 'no'}",
      "Dry clean: #{sample.dry_clean ? 'yes' : 'no'}"
    ].join(". ")

    instructions_llm = RubyLLM.chat(model: "gpt-4.1-nano")
    instructions_llm.with_instructions(DRAWER_INSTRUCTIONS_SYSTEM_PROMPT)
    response = instructions_llm.ask(
      "Write step-by-step washing instructions for a drawer of clothes with these care settings: #{settings}."
    )

    drawer.update_column(:instructions, response.content)
  end
end
# rubocop:enable Metrics/ClassLength
