class Legacy::AccredPref < Legacy::BaseCv
  self.table_name = 'accreds'
  self.primary_key = nil

  def self.by_sciper(sciper)
    self.where(sciper: sciper).order(:ordre)
  end

  def order
    self.ordre
  end

  def unit_id
    self.unit
  end

  def hidden?
    self.accred_show == 0
  end
end