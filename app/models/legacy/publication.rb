class Legacy::Publication < Legacy::BaseCv
  self.table_name = 'publications'
  belongs_to :cv, :class_name => "Cv", :foreign_key => "sciper"

  scope  :visible, -> { where(showpub: '1').order(:ordre) }

  def author
    self.auteurspub    
  end
  def title
    self.titrepub
  end
  def journal
    self.revuepub
  end
  def url
    self.urlpub
  end
end
