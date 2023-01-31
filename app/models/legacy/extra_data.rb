class Legacy::ExtraData < Legacy::BaseCv
  self.table_name = 'common'
  self.primary_key = 'sciper'
  belongs_to :cv, :class_name => "Cv", :foreign_key => "sciper"
end
