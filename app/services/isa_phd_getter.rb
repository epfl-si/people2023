# curl https://isa.epfl.ch/services/teachers/103561/thesis/directors/doctorants | jq
# ssh peo1 "curl 'https://isa.epfl.ch/services/teachers/103561/thesis/directors/doctorants'" | jq
class IsaPhdGetter < ApplicationService
  attr_reader :url, :id
  def initialize(sciper)
    @id=sciper
    @url = Rails.configuration.isa_url + "/teachers/#{sciper}/thesis/directors/doctorants"
  end
  def expire_in
    72.hours
  end
end
