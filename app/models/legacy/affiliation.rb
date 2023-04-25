# Attempt to have a class that works for all kind of people
class Legacy::Affiliation
  attr_reader :class_delegate, :unit, :address, :phones, :hierarchy, :position, :rooms
  def initialize(accred, atela_accred, sex)
    @accred = accred
    @position = accred.position
    @class_delegate = accred.class_delegate
    @unit = accred.unit

    if atela_accred.nil?
      @address = nil
      @phones = nil
      @rooms = nil
    else
      @address = atela_accred.address
      @phones = atela_accred.phones
      @hierarchy = atela_accred.hierarchy
      @rooms = atela_accred.rooms
    end
    @sex = sex
  end
  def t_position(lang=I18n.locale)
    @accred.function
  end
  def room
    @rooms.present? ? @rooms.first : nil
  end
end
