class Legacy::AccredPref < Legacy::BaseCv
  self.table_name = 'accreds'
  self.primary_key = nil

  def self.by_sciper(sciper)
    self.where(sciper: sciper).order(:ordre)
  end

  def self.visible_by_sciper(sciper)
    self.where(sciper: sciper, accred_show: 1).order(:ordre)
  end
end