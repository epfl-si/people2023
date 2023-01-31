class AtelaAccredsGetter < ApplicationService
  attr_reader :id
  
  def initialize(sciper)
    @id = sciper
  end

  def fetch
    url="#{ENV.fetch("ATELA_BACKEND_URL")}/getPerson/#{@id}"
    key=ENV.fetch("ATELA_KEY")
    uri=URI.parse(url)
    opts={:use_ssl => true, :read_timeout => 100}
    req = Net::HTTP::Post.new(uri)
    req['authorization'] = key
    res = Net::HTTP.start(uri.hostname, uri.port, opts) do |http|
      http.request(req)
    end
    case res
    when Net::HTTPSuccess then
      JSON.parse(res.body)
    else
      nil
    end
  end
end
