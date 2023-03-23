class Legacy::Affiliation
  attr_reader :class_delegate, :unit, :address, :phones, :hierarchy, :position, :rooms
  def initialize(accred, atela_accred, sex)
    @position = accred.position
    @class_delegate = accred.class_delegate
    @unit = accred.unit

    @address = atela_accred.address
    @phones = atela_accred.phones
    @hierarchy = atela_accred.hierarchy
    @rooms = atela_accred.rooms

    @sex = sex
  end
  def t_position(lang)
    case lang
    when "en"
      @position.labelen
    else
      @sex == "M" ? @position.labelfr : @position.labelxx
    end
  end
  def room
    @rooms.first
  end
end
