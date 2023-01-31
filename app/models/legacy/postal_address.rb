class Legacy::PostalAddress < Legacy::BaseDinfo
	self.table_name = 'adrspost'
	self.primary_key = nil
	belongs_to :person, :class_name => "Person", :foreign_key => "sciper"
	belongs_to :unit, :class_name => "Unit", :foreign_key => "unite"
end
