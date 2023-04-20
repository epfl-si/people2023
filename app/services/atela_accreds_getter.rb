# curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
class AtelaAccredsGetter < ApplicationService
  attr_reader :url, :id
  
  def initialize(sciper)
    @id=sciper
    @url = Rails.configuration.atela_backend_url + "/getPerson/#{sciper}"
  end

  def req_params
    {
      'authorization' => "People.key " + ENV.fetch("ATELA_KEY")
    }
  end
end
