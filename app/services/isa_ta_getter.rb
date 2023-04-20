class IsaTaGetter < IsaGetter
  def url
    @url ||= Rails.configuration.isa_url + "/teachers/#{@id}"
  end
end
