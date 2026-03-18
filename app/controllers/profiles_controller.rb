class ProfilesController < ApplicationController
  before_action :set_machine_data, only: %i[new create]

  def new
    @profile = Profile.new
    @profile.machines.build # builds one machine for the form
    @profiles = Profile.includes(:machines)
  end

  def create
    @profile = Profile.new(profile_params)
    @profile.user = current_user

    if @profile.save
      if params[:commit] == "Create Profile"
        redirect_to new_profile_path, notice: "Profile added."
      else
        redirect_to profiles_path
      end
    else
      @profiles = Profile.includes(:machines)
      render :new
    end
  end

  def index
    @profiles = Profile.includes(:machines)
  end

  def destroy
    Profile.find(params[:id]).destroy
    redirect_to profiles_path, notice: "Profile deleted."
  end

  private

  def profile_params
    params.require(:profile).permit(
      :name,
      machines_attributes: %i[brand model]
    )
  end

  def set_machine_data
    @machine_brands = Machine::BRANDS
    @machine_models = Machine::MODELS
  end
end
