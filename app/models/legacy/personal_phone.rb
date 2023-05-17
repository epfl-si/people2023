# in the annuaire_persphones the unit_id column is not necessarily integer but
# can be "default".
class Legacy::PersonalPhone < Legacy::BaseBottin
  self.table_name = 'annuaire_persphones'
  self.primary_key = nil
  belongs_to :phone, :class_name => "Phone", :foreign_key => "phone_id"
  belongs_to :room, :class_name => "Room", :foreign_key => "room_id"

  default_scope {
    joins(:phone).where("annuaire_persphones.valid_from < ? AND (annuaire_persphones.valid_to > ? OR annuaire_persphones.valid_to IS NULL)", DateTime.now, DateTime.now)
  }

  scope :default, -> {where(unit_id: "default")}

  def <=>(other)
    self.phone_order <=> other.phone_order
  end


  def hidden?
    self.phone_hidden
  end

  def visible?
    ! self.phone_hidden
  end

  # default_scope {
  #   where("annuaire_persphones.valid_from < ? AND (annuaire_persphones.valid_to > ? OR annuaire_persphones.valid_to IS NULL)", DateTime.now, DateTime.now).includes(:phone)
  # }

end

