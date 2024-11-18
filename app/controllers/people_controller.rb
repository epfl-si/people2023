# frozen_string_literal: true

class PeopleController < ApplicationController
  # protect_from_forgery
  layout 'public'

  def show
    r = Redirect.for_sciper_or_name(params[:sciper_or_name])
    redirect_to(r.url, allow_other_host: true) and return if r.present?

    set_common_data

    # @profile will be
    #   - nil if @person is not allowed to have a profile
    #   - new with default values if @person is allowed to edit profile but never did
    #   - persisted if @person did edit his profile in which case we can use the standard view
    # During migration (Rails.configuration.legacy_support)
    @profile = @person&.profile!

    # A new (absent) profile will be rendered using legacy (readonly) data
    if Rails.configuration.legacy_support && @profile && !@profile.persisted?
      set_legacy_profile_data
      render 'legacy'
    end

    logger.debug(@profile.inspect)

    # If @profile is not nil then the person is allowed to have a profile
    set_profile_data if @profile

    logger.debug("profile is persisted? #{@profile.present? and @profile.persisted?}")

    @page_title = "EPFL - #{@person.name.display}"
    respond_to do |format|
      format.html do
        ActiveSupport::Notifications.instrument('profile_controller_render') do
          render
        end
      end
      format.vcf { render layout: false }
    end
  end

  private

  def set_legacy_profile_data
    set_common_data
  end

  # Set the data that is present for any existing Person. That is the part
  # of the profile page that is not editable withing people and which relies
  # only on data coming from external sources.
  def set_common_data
    # ActiveSupport::Notifications.instrument('set_base_data') do
    # end
    @person = Person.find(params[:sciper_or_name])
    raise ActiveRecord::RecordNotFound if @person.blank?

    all_accreds = @person.accreditations
    @accreds = all_accreds.select(&:visible?)
    @accreds = all_accreds.select { |a| a.visible?(hide_teacher_accreds: false) } if @accreds.empty?
    raise ActiveRecord::RecordNotFound if @accreds.empty?

    @accreds.sort!

    @sciper = @person&.sciper

    compute_audience(@sciper)
    # @admin_data = @audience > 1 ? @person.admin_data : nil
  end

  def set_profile_data
    # teachers are supposed to all have a profile
    @ta = Isa::Teaching.new(@sciper) if @person.possibly_teacher?
    if @ta.present?
      @current_phds = @ta.phd.select(&:current?)
      @past_phds = @ta.phd.select(&:past?)
      @teachings = @ta.primary_teaching + @ta.secondary_teaching + @ta.doctoral_teaching
    else
      @current_phds = nil
      @past_phds = nil
      @teachings = nil
    end
    @courses = @profile.courses.group_by { |c| c.t_title(I18n.locale) }

    @profile_picture = @profile.photo.image if @profile.photo&.image&.attached?
    # @profile_picture = @profile.photo.image if @profile.show_photo && @profile.photo.image.attached?
    @visible_socials = @profile.socials.for_audience(@audience)

    # TODO: should we simply redirect to the page with selected locale ? May
    #       be not because this is just for user provided content and not for
    #       automatic adata like accreds etc.
    # User's provided data (boxes) is coerced to @profile.force_lang locale
    @cvlocale = @profile.force_lang || I18n.locale
    logger.debug("sciper: #{@sciper} locale=#{I18n.locale} cvlocale=#{@cvlocale}")

    # get sections that contain at least one box in the chosen locale
    unsorted_boxes = @profile.boxes.for_audience(@audience).includes(:section).select do |b|
      b.content?(@cvlocale)
    end
    @boxes = unsorted_boxes.sort do |a, b|
      [a.section.position, a.position] <=> [b.section.position, b.position]
    end
    @boxes_by_section = @boxes.group_by(&:section)

    @contact_zone_bbs = @boxes_by_section.select { |s, _b| s.zone == "contact" }
    @main_zone_bbs = @boxes_by_section.select { |s, _b| s.zone == "main" }

    # @contact_sections = []
    # @main_sections = []
  end
end
