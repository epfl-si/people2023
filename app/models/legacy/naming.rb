class Legacy::Naming < Legacy::BaseDinfo
  self.table_name = 'sciper'
  self.primary_key = 'sciper'
  def display_name
    @display_name ||= "#{self.prenom_usuel || self.prenom_acc} #{self.nom_usuel || self.nom_acc}"
  end
end
