class Legacy::Delegate < Legacy::BaseDinfo
  self.table_name = 'delegues'
  self.primary_key = 'sciper'

  def full_section
    @full_section
  end
end
