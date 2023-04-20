class IsaPhdGetter < IsaGetter  
  def url
    @url ||= Rails.configuration.isa_url + "/teachers/#{@id}/thesis/directors/doctorants"
  end
end
