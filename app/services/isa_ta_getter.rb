# curl https://isa.epfl.ch/services/teachers/103561 | jq
# ssh peo1 "curl 'https://isa.epfl.ch/services/teachers/103561'" | jq
class IsaTaGetter < ApplicationService
  attr_reader :url, :id
  def initialize(sciper)
    @id=sciper
    @url = Rails.configuration.isa_url + "/teachers/#{sciper}"
  end

  def expire_in
    72.hours
  end
end
