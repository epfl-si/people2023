# frozen_string_literal: true

class ExperiencesController < ApplicationController
  before_action :set_profile, only: %i[index create new]
  before_action :set_experience, only: %i[show edit update destroy]

  # GET /profile/profile_id/experiences or /profile/profile_id/experiences.json
  def index
    # sleep 2
    @experiences = @profile.experiences.order(:position)
  end

  # GET /profile/profile_id/experiences/1 or /profile/profile_id/experiences/1.json
  def show; end

  # GET /profile/profile_id/experiences/new
  def new
    @experience = Experience.new
  end

  # GET /profile/profile_id/experiences/1/edit
  def edit; end

  # POST /profile/profile_id/experiences or /experiences.json
  def create
    @experience = @profile.experiences.new(experience_params)

    respond_to do |format|
      if @experience.save
        flash.now[:success] = "Updated succesfully!"
        format.html { append_experience }
        format.turbo_stream { render :create, locals: { profile: @profile, experience: @experience } }
        format.json { render :show, status: :created, location: @experience }
      else
        flash.now[:success] = "Failed to update :("
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render :new, status: :unprocessable_entity, locals: { profile: @profile, experience: @experience }
        end
        format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /experiences/1 or /experiences/1.json
  def update
    respond_to do |format|
      if @experience.update(experience_params)
        format.html { redirect_to experience_url(@experience), notice: "Experience was successfully updated." }
        format.turbo_stream { render :update }
        format.json { render :show, status: :ok, location: @experience }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @experience.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profile/profile_id/experiences/1 or /profile/profile_id/experiences/1.json
  def destroy
    @experience.destroy!

    respond_to do |format|
      format.html { redirect_to experiences_url, notice: "Experience was successfully destroyed." }
      format.turbo_stream { render :destroy }
      format.json { head :no_content }
    end
  end

  private

  def append_experience
    render turbo_stream: turbo_stream.append("jobs",
                                             partial: "editable_experience",
                                             locals: { experience: @experience })
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_experience
    @experience = Experience.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def experience_params
    params.require(:experience).permit(:location, :title_fr, :title_en, :year_begin, :year_end, :audience, :visible,
                                       :position)
  end
end
