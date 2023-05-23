class Legacy::PostalAddress < Legacy::BaseBottin
	self.table_name = 'annuaire_adrspost'
	self.primary_key = nil
	belongs_to :person, :class_name => "Person", :foreign_key => "pers_id"
	belongs_to :unit, :class_name => "Unit", :foreign_key => "unit_id"

	default_scope {
		where("valid_from < ? AND (valid_to > ? OR valid_to IS NULL)", DateTime.now, DateTime.now)
	}

	# def unit_id
	# 	self.unite
	# end

	def person_id
		self.pers_id
	end

	def sciper
		self.pers_id
	end

	# return all the lines in adr
	def lines
		self.adr.nil? ? [] : self.adr.split(" $ ")
	end

	# return all the lines in addr except the first one (affiliation hierarchy)
	def address_lines
		self.adr.nil? ? [] : self.adr.split(" $ ")[1..]
	end

  def full
    self.adr
  end

  def country
  	self.pays
  end

  # def t_country(lang=I18n.locale)
  # 	lang.to_s == "fr" ? self.pays : self.country
  # end

end
