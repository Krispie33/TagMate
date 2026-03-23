class DrawersController < ApplicationController
  before_action :set_drawer, only: [:show, :destroy]

  def index
    @drawers = current_user.drawers
  end

  def show
    @clothing_items = @drawer.clothing_items
  end

  def destroy
    @drawer.destroy
    redirect_to drawers_path, notice: "Drawer deleted."
  end

  private

  def set_drawer
    @drawer = current_user.drawers.find(params[:id])
  end
end
