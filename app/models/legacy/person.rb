class Legacy::Person < Legacy::BaseDinfo
  self.table_name = 'sciper'
  self.primary_key = 'sciper'

  has_one  :email, :class_name => "Email", :foreign_key => "sciper"

  has_many :active_accreds, -> { where("#{Legacy::Accreditation.table_name}.finval IS NULL OR #{Legacy::Accreditation.table_name}.finval > ?", Date.today.strftime).order(:ordre).joins(:position) }, :class_name => "Accreditation", :foreign_key => "persid"
  has_many :active_units, :class_name => "Unit", :through => :active_accreds, :foreign_key => "persid", :source => "unit"
  has_many :active_positions, :class_name => "Position", :through => :active_accreds, :foreign_key => "persid", :source => "position"

  has_many :policies, :class_name => "Policy", :foreign_key => "persid"
  has_many :active_policies, -> { where("#{Legacy::Policy.table_name}.finval IS NULL OR #{Legacy::Policy.table_name}.finval > ?", Date.today.strftime) }, :class_name => "Policy", :foreign_key => "persid"
  has_many :active_properties, :class_name => "Property", :through => :active_policies, :foreign_key => "persid", :source => "property"

  has_many :accred_prefs, :class_name => "AccredPref", :foreign_key => "sciper"

  def affiliations
    active_accreds.map{|a| Legacy::Affiliation.new(a, atela.accreds[a.unitid], sex)}
  end

  def atela
    @atela ||= Atela::Person.new(self.sciper)
  end

  def birthday
    self.date_naiss
  end

  def can_edit_profile?
    self.active_accreds.any? {|a| a.can_edit_profile?} ||
      self.active_properties.map{|p| p.id}.include?(7) ||
        self.active_positions.map{|p| p.labelfr}.include?('Professeur honoraire')
  end

  def display_name
    @display_name ||= "#{self.prenom_usuel || self.prenom_acc} #{self.nom_usuel || self.nom_acc}"
  end

  def email_address
    self.email.addrlog
  end

  def phone
    atela.phone
  end

  def room 
    atela.room
  end

  def sex
    self.sexe
  end

  def units
    self.accreditations.map{|a| a.unit }
  end

  def username
    atela.username
  end

  def visible_units
    self.accreditations.select{|a| a.accred_show == "1"}.map{|a| a.unit }
  end
end
