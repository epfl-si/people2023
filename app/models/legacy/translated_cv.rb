class Legacy::TranslatedCv < Legacy::BaseCv
  self.table_name = 'cv'
  self.primary_key = 'sciper'
  has_many :accreditations, :class_name => "Accreditation", :foreign_key => "sciper", :inverse_of => "cv"
  has_many :educations,     :class_name => "Education", :foreign_key => "sciper"
  has_many :experiences,    :class_name => "Experience", :foreign_key => "sciper"
  has_many :publications,   :class_name => "Publication", :foreign_key => "sciper"
  has_many :social_ids, -> { order 'ordre' }, :class_name => "SocialId", :foreign_key => "sciper"

  has_many :teaching_activities, :class_name => "TeachingActivity", :foreign_key => "sciper"
  has_one  :data, :class_name => "CommonData", :foreign_key => "sciper"

  # has_many relation does not work because not on the same DB :_(
  # has_many :units, :class_name => "Dinfo::Unit", through: :accreditations
  def units
    self.accreditations.map{|a| a.unit }
  end

  def visible_units
    self.accreditations.select{|a| a.accred_show == "1"}.map{|a| a.unit }
  end

  def visible_social_ids
    # needs to be sorted after db fetch because most of the "ordre" entries
    # are NULL. Therefore, we mostly sort by the default order
    self.social_ids.where("id_show = '1' AND content IS NOT NULL").sort{|a,b| a.order <=> b.order}
  end

  def show_photo?
    self.photo_show == "1"
  end

  def method_missing(method_id, *arguments, &block)
    if self.data.respond_to?(method_id)
      self.data.send(method_id, *arguments)
    else
      super
    end
  end

  # TODO
  def photo_url
    "https://via.placeholder.com/400"
  end
end
