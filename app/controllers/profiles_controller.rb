class ProfilesController < ApplicationController
  before_action :set_machine_data, only: %i[new create]

  def new
    @profile = Profile.new
    @profile.machines.build # builds one machine for the form
    @profiles = current_user.profiles.includes(:machines)
  end

  def create
    if current_user.profiles.count >= 5
      @profiles = current_user.profiles.includes(:machines)
      @profile = Profile.new
      @profile.machines.build
      flash.now[:alert] = "You can only create up to 5 profiles."
      render :new, status: :unprocessable_entity
      return
    end

    @profile = current_user.profiles.build(profile_params)

    if @profile.save
      if params[:commit] == "Create Profile"
        redirect_to new_profile_path, notice: "Profile added."
      else
        redirect_to profiles_path
      end
    else
      @profiles = current_user.profiles.includes(:machines)
      @profile.machines.build if @profile.machines.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    Profile.find(params[:id]).destroy
    redirect_to new_profile_path, notice: "Profile deleted."
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
