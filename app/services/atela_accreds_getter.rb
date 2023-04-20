class AtelaAccredsGetter < ApplicationService
  attr_reader :id
  
  def initialize(sciper)
    @id = sciper
  end

  def fetch
    # curl -H 'Authorization: People.key ATELA_KEY' https://atela.epfl.ch/cgi-bin/atela-backend/getPerson/121769
    url=Rails.configuration.atela_backend_url + "/getPerson/#{@id}"
    key="People.key " + ENV.fetch("ATELA_KEY")
    uri=URI.parse(url)
    opts={:use_ssl => true, :read_timeout => 100}
    req = Net::HTTP::Get.new(uri)
    req['authorization'] = key
    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPOK then
      JSON.parse(res.body)
    else
      nil
    end
  end
end
