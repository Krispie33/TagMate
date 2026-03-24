class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :tips]

  def home
    @profile = Profile.find_by(user: current_user)
    @drawer = Drawer.find_by(profile: @profile)
  end

  def tips
  end
end
