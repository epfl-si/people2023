class Legacy::Box < Legacy::BaseCv
  self.table_name = 'boxes'
  self.primary_key = 'sciper'
  belongs_to :cv, :class_name => "Cv", :foreign_key => "sciper"

end
