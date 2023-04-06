class LegacyController < ApplicationController
  layout "legacy"

  def show0
    common_show_data
  end

 private
  def common_show_data
    sciper_or_name = params[:sciper_or_name]
    @sciper = nil
    if sciper_or_name =~ /^\d{6}$/
      @sciper = sciper_or_name
      @email = Legacy::Email.find(@sciper)
    else 
      @email = Legacy::Email.where("addrlog = ? OR addrlog LIKE ?", "#{sciper_or_name}@epfl.ch", "#{sciper_or_name}@epfl.%").first
      @sciper=@email.sciper unless @email.nil?
    end
    @person = Legacy::Person.find(@sciper)
    # @cv can be nil because not everybody can edit his personal page
    # @cv = Legacy::Cv.find(@sciper)
    @cv = Legacy::Cv.where(sciper: @sciper).first
    @editable = !@cv.nil? && @person.can_edit_profile?
    if @editable
      @tcv = @cv.translated_part(I18n.locale)
      bb = @cv.translated_boxes(I18n.locale).order(:position, :ordre)
      @boxes={}
      ['K', 'B', 'P', 'R', 'T'].each do |k|
        @boxes[k] = bb.select{|b| b.position == k}
      end
    end
  end
end
