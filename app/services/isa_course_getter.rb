# TODO: waiting for Tim to adapt the ISA api. In the mean time I use the old people
class IsaCourseGetter < ApplicationService
  attr_reader :url, :id
  def initialize(sciper)
    # @url ||= Rails.configuration.isa_url + "/courses/#{@id}"
    @id=sciper
    @url = "https://people.epfl.ch/cgi-bin/getCoursData/?sciper=#{sciper}"
  end
end
