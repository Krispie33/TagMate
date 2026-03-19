class ClothingItemsController < ApplicationController
  def index
    @clothing_items = ClothingItem.joins(drawer: :profile).where(profiles: { user_id: current_user.id })
  end

  def new
    @clothing_item = ClothingItem.new
    @drawer = Drawer.find(params[:drawer_id])
  end

  def create
    @clothing_item = ClothingItem.new(clothing_item_params)
    @drawer = Drawer.find(params[:drawer_id])
    @clothing_item.drawer = @drawer
    @clothing_item.user = current_user
    if @clothing_item.save
      redirect_to @clothing_item, notice: "Clothing item saved successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @clothing_item = ClothingItem.joins(drawer: :profile).where(profiles: { user_id: current_user.id }).find(params[:id])
  end

  private

  def clothing_item_params
    params.require(:clothing_item).permit(:care_summary, :tag_image, :item_image)
  end
end
