# class Legacy::AccredDisplay < Legacy::BaseCv
#   self.table_name = 'accreds'
#   self.primary_key = nil
#   # belongs_to :unit, :class_name => "Unit", :foreign_key => "unit"
#   # belongs_to :cv,   :class_name => "Cv", :foreign_key => "sciper"
# end

class Legacy::Accreditation < Legacy::BaseAccred
  self.table_name = 'accreds'
  self.primary_key = nil
  belongs_to :unit, :class_name => "Unit", :foreign_key => "unitid"
  belongs_to :person, :class_name => "Person", :foreign_key => "sciper"
  belongs_to :position, :class_name => "Position", :foreign_key => "posid"
  belongs_to :status, :class_name => "Status", :foreign_key => "statusid"
  def unit_id
    self.unite
  end

  def display
    Legacy::AccredDisplay.where(sciper: self.sciper, unit: self.unit_id).first
  end

  def can_edit_profile?
    # ["Staff", "Student"].include?(self.status.labelen)
    [1, 5].include?(self.statusid)
  end

  def is_student?
    # ["External student", "Student", "Alumni"].include?(self.status.labelen)
    [4, 5, 6].include?(self.statusid)
  end
end
