class Legacy::TranslatedCv < Legacy::BaseCv
  self.table_name = 'cv'
  self.primary_key = 'sciper'

  has_many :boxes, -> (object) {where cvlang: object.cvlang }, :class_name => "Box", :foreign_key => "sciper"
  has_many :publication_boxes, -> (object) {where cvlang: object.cvlang }, :class_name => "PublicationBox", :foreign_key => "sciper"
  has_many :infosciences, -> (object) {where cvlang: object.cvlang }, :class_name => "Infoscience", :foreign_key => "sciper"

  def title
    self.titre
  end

  def visible_title?
    self.titre_show == "1" && self.titre.present?
  end
  def visible_expertise?
    self.expertise_show == "1" && self.expertise.present?
  end

  def any_publication?
    self.infosciences.present? or self.publications_boxes.present?
  end

  # def method_missing(method_id, *arguments, &block)
  #   if self.data.respond_to?(method_id)
  #     self.data.send(method_id, *arguments)
  #   else
  #     super
  #   end
  # end

end
