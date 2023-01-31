class Legacy::Unit < Legacy::BaseDinfo
	self.table_name = 'allunits'
	self.primary_key = 'id_unite'

	has_many :accreditations, :class_name => "Accreditation", :foreign_key => "unitid"

end
