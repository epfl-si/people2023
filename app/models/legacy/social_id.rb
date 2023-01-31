class Legacy::SocialId < Legacy::BaseCv
  self.table_name = 'research_ids'
  belongs_to :cv, :class_name => "Cv", :foreign_key => "sciper"
end
