# Extended accred including address, phones, people preferences
class Legacy::Affiliation < Legacy::Accreditation
  attr_reader :address

  def <=>(other)
    self.order <=> other.order
  end

  def hidden?
    @prefs.present? and @prefs.hidden?
  end

  def visible?
    not hidden?
  end

  def phones=(o)
    @phones = o.sort
  end

  def address=(a)
    @address = a
  end

  def prefs=(p)
    @prefs = p
  end

  def order
    @prefs.present? ? @prefs.order : super
  end

  def phones
    @phones
  end

  def visible_phones
    @phones.select{|p| p.visible?}.sort #.map{|p| p.phone}
  end

  def phone
    @phones.present? ? @phones.sort.first : nil
  end

  # def room
  #   @phones.present? ? @phones.local : nil
  # end

end
