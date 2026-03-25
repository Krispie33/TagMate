class ClothingItemsController < ApplicationController
  TAG_ANALYSIS_SYSTEM_PROMPT = <<~PROMPT
    You are a laundry care label expert. Analyse the clothing care label symbols and text in the image.
    Return ONLY a valid JSON object with these exact fields — no markdown, no explanation, just JSON:
    {
      "wash_temp": <integer in Celsius, e.g. 30, 40, 60 — use null for cold/hand wash or if unspecified>,
      "bleach_allowed": <boolean — true only if a bleach symbol without a cross is shown>,
      "tumble_dry": <boolean — true if tumble drying is permitted>,
      "iron_allowed": <boolean — true if ironing is permitted>,
      "dry_clean": <boolean — true if a dry-clean circle symbol is shown>,
      "care_summary": <string — comma-separated list of all five care instructions in this exact style: "Hand wash" or "Wash at 30°C" / "Wash at 40°C" / "Wash at 60°C" / "Wash at 90°C", "NO bleach" or "Bleach OK", "NO tumble dry" or "Tumble dry OK", "Iron on LOW/MED/HIGH" or "NO iron", "Dry clean OK" or "NO dry clean">
    }
  PROMPT

  def drawer_instructions(brand, model)
    drawer_instructions_system_prompt = <<~PROMPT
      You are a laundry assistant helping a young adult do their first laundry.
      Write clear, actionable washing instructions for a drawer of clothes that all share the same care settings.
      Provide the recommended washing machine program setting for #{brand} brand and #{model} model. Also specify the suitable rpm.
      Use simple language and plain text only — no Markdown, no asterisks, no symbols.
      Use 5 numbered steps. Keep it under 75 words.
    PROMPT
  end

  before_action :require_profile!, only: %i[new create]
  before_action :set_clothing_item, only: %i[show destroy]

  def index
    @clothing_items = current_user.clothing_items
  end

  def new
    @clothing_item = ClothingItem.new
  end

  def show
  end

  def destroy
    @clothing_item.destroy
    redirect_to clothing_items_path, notice: "Item deleted."
  end

  def create
    tag_file = params.dig(:clothing_item, :tag_image)
    redirect_to new_clothing_item_path, alert: "Please attach a tag image." and return unless tag_file

    item_file = params.dig(:clothing_item, :item_image)

    item = current_user.clothing_items.new
    item.tag_image.attach(tag_file)
    item.item_image.attach(item_file) if item_file
    item.save(validate: false)

    care_data = extract_care_data(item.tag_image)
    drawer    = find_or_create_drawer(care_data)

    item.update_columns(
      wash_temp: care_data["wash_temp"],
      bleach_allowed: care_data["bleach_allowed"] || false,
      tumble_dry: care_data["tumble_dry"] || false,
      iron_allowed: care_data["iron_allowed"] || false,
      dry_clean: care_data["dry_clean"] || false,
      care_summary: care_data["care_summary"],
      ai_raw_response: care_data,
      drawer_id: drawer.id
    )

    update_drawer_instructions(drawer)
    redirect_to drawer_path(drawer), notice: "Tag analysed and item added to '#{drawer.name}'."
  rescue JSON::ParserError
    item&.destroy
    redirect_to new_clothing_item_path, alert: "Could not read the care label. Please try again with a clearer image."
  end

  private

  def set_clothing_item
    @clothing_item = current_user.clothing_items.find(params[:id])
  end

  def require_profile!
    return if current_user.profiles.exists?

    redirect_to new_profile_path, alert: "Please create a profile before scanning clothes."
  end

  def extract_care_data(attachment)
    llm = RubyLLM.chat(model: "gpt-4o")
    llm.with_instructions(TAG_ANALYSIS_SYSTEM_PROMPT)
    response = llm.ask(
      "Analyse this clothing care label and return the JSON object described in the instructions.",
      with: { image: attachment.url }
    )
    content = response.content.strip.gsub(/\A```(?:json)?\n?/, "").gsub(/\n?```\z/, "")
    JSON.parse(content)
  end

  def find_or_create_drawer(care_data)
    name    = drawer_name_for(care_data)
    profile = current_user.profiles.first
    profile.drawers.find_or_create_by!(name: name)
  end

  def drawer_name_for(care_data)
    if care_data["wash_temp"]
      "#{care_data['wash_temp']}°C Wash"
    elsif care_data["wash_temp"].nil?
      "Cold / Hand Wash"
    else # care_data["dry_clean"]
      "Dry Clean Only"
    end
  end

  def update_drawer_instructions(drawer)
    item = drawer.clothing_items.reload.first
    return unless item

    settings = [
      "Wash at #{item.wash_temp || 'cold'}°C",
      "Bleach: #{item.bleach_allowed ? 'allowed' : 'not allowed'}",
      "Tumble dry: #{item.tumble_dry ? 'yes' : 'no'}",
      "Iron: #{item.iron_allowed ? 'yes' : 'no'}",
      "Dry clean: #{item.dry_clean ? 'yes' : 'no'}"
    ].join(". ")

    profile = drawer.profile
    machine = profile.machines.first

    brand = machine.brand
    model = machine.model

    llm = RubyLLM.chat(model: "gpt-4.1-nano")
    llm.with_instructions(drawer_instructions(brand, model))
    response = llm.ask("Write step-by-step washing instructions for a drawer of clothes with these care settings: #{settings}.")
    drawer.update_column(:instructions, response.content)
  end
end
