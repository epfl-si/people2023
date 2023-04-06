class Legacy::Award < Legacy::BaseCv
  self.table_name = 'awards'
  belongs_to :cv, :class_name => "Cv", :foreign_key => "sciper"
end
