# rubocop:disable Metrics/ClassLength
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
      "care_summary": <string — one concise sentence describing all care instructions>
    }
  PROMPT

  DRAWER_INSTRUCTIONS_SYSTEM_PROMPT = <<~PROMPT
    You are a laundry assistant helping a young adult do their first laundry.
    Write clear, actionable washing instructions for a drawer of clothes that all share the same care settings.
    Use simple language and plain text only — no Markdown, no asterisks, no symbols.
    Use numbered steps. Keep it under 150 words.
  PROMPT

  def index
    @clothing_items = current_user.clothing_items
  end

  def new
    @clothing_item = ClothingItem.new
    @drawer = params[:drawer_id] ? Drawer.find(params[:drawer_id]) : nil
  end

  def create
    params[:drawer_id] ? create_manual : create_from_tag
  end

  def show
    @clothing_item = current_user.clothing_items.find(params[:id])
  end

  private

  # Manual creation nested under an existing drawer
  def create_manual
    @drawer = Drawer.find(params[:drawer_id])
    @clothing_item = ClothingItem.new(clothing_item_params)
    @clothing_item.drawer = @drawer
    @clothing_item.user = current_user
    if @clothing_item.save
      redirect_to @clothing_item, notice: "Clothing item saved successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Tag-image scan — LLM analyses the tag and auto-assigns the item to the right drawer
  def create_from_tag
    tag_file = params.dig(:clothing_item, :tag_image)
    unless tag_file
      redirect_to new_clothing_item_path, alert: "Please attach a tag image." and return
    end

    # Attach the file to a temporary item first so we get an ActiveStorage URL for the LLM
    temp_item = current_user.clothing_items.new
    temp_item.tag_image.attach(tag_file)
    temp_item.save(validate: false)

    care_data = extract_care_data(temp_item.tag_image)
    drawer    = find_or_create_drawer_for(care_data)
    temp_item.update_columns(
      wash_temp:       care_data["wash_temp"],
      bleach_allowed:  care_data["bleach_allowed"] || false,
      tumble_dry:      care_data["tumble_dry"]     || false,
      iron_allowed:    care_data["iron_allowed"]   || false,
      dry_clean:       care_data["dry_clean"]      || false,
      care_summary:    care_data["care_summary"],
      ai_raw_response: care_data,
      drawer_id:       drawer.id
    )
    update_drawer_instructions(drawer)
    redirect_to drawer_path(drawer), notice: "Tag analysed and item added to '#{drawer.name}'."
  rescue JSON::ParserError
    temp_item&.destroy
    redirect_to new_clothing_item_path, alert: "Could not read the care label. Please try again with a clearer image."
  end

  def clothing_item_params
    params.require(:clothing_item).permit(:care_summary, :tag_image, :item_image)
  end

  def extract_care_data(attachment)
    llm = RubyLLM.chat(model: "gpt-4o")
    llm.with_instructions(TAG_ANALYSIS_SYSTEM_PROMPT)
    raw = llm.ask(
      "Analyse this clothing care label and return the JSON object described in the instructions.",
      with: { image: attachment.url }
    )
    JSON.parse(raw.content)
  end

  # Finds a drawer with matching wash settings, or creates a new one
  def find_or_create_drawer_for(care_data)
    wash_temp = care_data["wash_temp"]
    dry_clean = care_data["dry_clean"]
    profile   = current_user.profiles.first

    matching = profile&.drawers
                       &.joins(:clothing_items)
                       &.where(clothing_items: { wash_temp: wash_temp, dry_clean: dry_clean })
                       &.first

    matching || build_and_save_drawer(care_data, profile)
  end

  def build_and_save_drawer(care_data, profile)
    name = if care_data["dry_clean"]
             "Dry Clean Only"
           elsif care_data["wash_temp"].nil?
             "Cold / Hand Wash"
           else
             "#{care_data['wash_temp']}°C Wash"
           end

    drawer = (profile || current_user).drawers.new(name: name)
    drawer.save(validate: false)
    drawer
  end

  # Asks the LLM to write washing instructions for all items in the drawer
  def update_drawer_instructions(drawer)
    items = drawer.clothing_items.reload
    return if items.empty?

    sample   = items.first
    settings = [
      "Wash at #{sample.wash_temp || 'cold'}°C",
      "Bleach: #{sample.bleach_allowed ? 'allowed' : 'not allowed'}",
      "Tumble dry: #{sample.tumble_dry ? 'yes' : 'no'}",
      "Iron: #{sample.iron_allowed ? 'yes' : 'no'}",
      "Dry clean: #{sample.dry_clean ? 'yes' : 'no'}"
    ].join(". ")

    llm      = RubyLLM.chat(model: "gpt-4.1-nano")
    llm.with_instructions(DRAWER_INSTRUCTIONS_SYSTEM_PROMPT)
    response = llm.ask(
      "Write step-by-step washing instructions for a drawer of clothes with these care settings: #{settings}."
    )
    drawer.update_column(:instructions, response.content)
  end
end
# rubocop:enable Metrics/ClassLength
