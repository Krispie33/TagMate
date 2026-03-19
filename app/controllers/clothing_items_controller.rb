class ClothingItemsController < ApplicationController
  def index
    @clothing_items = current_user.clothing_items
  end

  def new
    @clothing_item = ClothingItem.new
  end

  def create
    @clothing_item = current_user.clothing_items.build(clothing_item_params)

    if @clothing_item.save
      LaundryTagReader.new(@clothing_item).process_tag!
      DrawerAssigner.new(@clothing_item).assign!

      redirect_to @clothing_item, notice: "Clothing item saved successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @clothing_item = current_user.clothing_items.find(params[:id])
  end

  private

  def clothing_item_params
    params.require(:clothing_item).permit(:name, :tag_image, :item_image)
  end
end
