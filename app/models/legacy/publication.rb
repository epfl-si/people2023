class Legacy::Publication < Legacy::BaseCv
  self.table_name = 'publications'
  belongs_to :cv, :class_name => "Cv", :foreign_key => "sciper"
end
