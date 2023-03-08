class LegacyController < ApplicationController
  layout "legacy"
  def show
    # @disable_nav = true
    sciper_or_name = params[:sciper_or_name]
    if sciper_or_name =~ /^\d{6}$/
      @person = Legacy::Person.find(sciper_or_name)
    else
      @person = Legacy::Person.find_by_name_dot_surname(sciper_or_name)
    end
    sciper=@person.sciper
    @page_title = "People / #{sciper}"
    # TODO use current language
    @cv = Legacy::Cv.where(sciper: sciper, cvlang: "en").first
    if @cv.nil?
      Rails.logger.warn("Cv for #{sciper} not found")
      render status: 404 if @cv.nil?
    end
  end
end
