class LegacyController < ApplicationController
  protect_from_forgery
  layout "legacy"

  def show0
    common_show_data
    respond_to do |format|
      format.html { render layout: 'legacy0'  }
    end
  end

  def show
    common_show_data
    respond_to do |format|
      format.html { render layout: 'legacy'  }
      format.vcf { render layout: false }
    end
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
    @page_title = "EPFL - #{@person.display_name}"
    # @cv can be nil because not everybody can edit his personal page
    # @cv = Legacy::Cv.find(@sciper)
    @cv = Legacy::Cv.where(sciper: @sciper).first
    @editable = !@cv.nil? && @person.can_edit_profile?
    if @person.possibly_teacher?
      @ta = Isa::Teaching.new(@sciper)
    else
      @ta = nil
    end
    if @editable
      @tcv = @cv.translated_part(I18n.locale)
      bb = @tcv.boxes.visible.with_content.order(:position, :ordre)
      @boxes={}
      ['K', 'B', 'P', 'R', 'T'].each do |k|
        @boxes[k] = bb.select{|b| b.position == k}
      end
      unless @boxes['B'].empty?
        @boxes['B'].first.label = "" if @boxes['B'].first.label == t("biography")
      end
    end
  end
end
