class DrawersController < ApplicationController
  def index
    @drawers = current_user.drawers
  end
  def show
    @drawer = Drawer.find(params[:id])
    @clothing_items = @drawer.clothing_items
  end

end
