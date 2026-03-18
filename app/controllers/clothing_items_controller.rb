class ClothingItemsController < ApplicationController
  def new
    @cloth = Cloth.new
  end

  def create
    @cloth = current_user.clothes.build(cloth_params)

    if @cloth.save
      redirect_to @cloth, notice: "Clothing item was uploaded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @cloth = current_user.clothes.find(params[:id])
  end

  private

  def cloth_params
    params.require(:cloth).permit(:name, :tag_image, :item_image)
  end
end
