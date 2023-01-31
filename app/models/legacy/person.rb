class Legacy::Person < Legacy::BaseDinfo
  self.table_name = 'sciper'
  self.primary_key = 'sciper'

  has_one  :data, :class_name => "ExtraData", :foreign_key => "sciper"
  has_one  :email, :class_name => "Email", :foreign_key => "sciper"
  has_one  :account, :class_name => "Account", :foreign_key => "sciper"
  has_many :cvs, :class_name => "Cv", :foreign_key => "sciper"
  has_many :educations,     :class_name => "Education", :foreign_key => "sciper"
  has_many :experiences,    :class_name => "Experience", :foreign_key => "sciper"
  has_many :publications,   :class_name => "Publication", :foreign_key => "sciper"
  has_many :social_ids,     :class_name => "SocialId", :foreign_key => "sciper"
  has_many :teaching_activities, :class_name => "TeachingActivity", :foreign_key => "sciper"

  has_many :offices, :class_name => "Office", :foreign_key => "sciper"
  has_many :postal_addresses, :class_name => "PostalAddress", :foreign_key => "sciper"

  has_many :accreds, :class_name => "Accreditation", :foreign_key => "persid"
  has_and_belongs_to_many :units, :join_table => "accreds", :foreign_key => "persid", :association_foreign_key => "unitid"

  # strftime is needed because we had to cast all datetimes into strings
  # explicit table name needed because col name is duplicate hence query ambiguous
  has_many :active_accreds, -> { where("#{Legacy::Accreditation.table_name}.finval IS NULL OR #{Legacy::Accreditation.table_name}.finval > ?", Date.today.strftime).order(:ordre) }, :class_name => "Accreditation", :foreign_key => "persid"
  has_many :active_units, :class_name => "Unit", :through => :active_accreds, :foreign_key => "persid", :source => "unit"
  has_many :active_positions, :class_name => "Position", :through => :active_accreds, :foreign_key => "persid", :source => "position"

  has_many :policies, :class_name => "Policy", :foreign_key => "persid"
  has_many :active_policies, -> { where("#{Legacy::Policy.table_name}.finval IS NULL OR #{Legacy::Policy.table_name}.finval > ?", Date.today.strftime) }, :class_name => "Policy", :foreign_key => "persid"
  has_many :active_properties, :class_name => "Property", :through => :active_policies, :foreign_key => "persid", :source => "property"

  def self.find_by_name_dot_surname(nds)
    e = Legacy::Email.where("addrlog = ? OR addrlog LIKE ?", "#{nds}@epfl.ch", "#{nds}@epfl.%").first
    raise ActiveRecord::RecordNotFound.new("Person with email base #{nds} not found") if e.nil?
    find(e.sciper)
  end

  def email_address
    self.email.addrlog
  end

  def main_phone
    if aa=atela_accreds
      phones = aa.values.map{|v| v["phones"]}
                 .flatten.sort{|a,b| a["phone_order"] <=> b["phone_order"]}
                 .map{|p| p["phone_nb"]}
    else
      phones = self.offices.map{|p| [p["telephone1"], p["telephone2"]]}.flatten.compact
    end
    phones.first
  end

  def can_edit_profile?
    self.active_accreds.any? {|a| a.can_edit_profile?} ||
      self.active_properties.map{|p| p.id}.include?(7) ||
        self.active_positions.map{|p| p.labelfr}.include?('Professeur honoraire')
  end

  # def method_missing(method_id, *arguments, &block)
  #   if self.data.respond_to?(method_id)
  #     self.data.send(method_id, *arguments)
  #   else
  #     super
  #   end
  # end

  # TODO: cache this because it is quie slow
  def atela_accreds
    @atela_accreds ||= AtelaAccredsGetter.call(self.sciper) || {}
    @atela_accreds.empty? ? nil : @atela_accreds["accreds"]
  end

end
