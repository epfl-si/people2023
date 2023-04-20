
# TODO: waiting for Tim to adapt the ISA api. In the mean time I use the old people
class IsaCourseGetter < IsaGetter
  def url
    # @url ||= Rails.configuration.isa_url + "/courses/#{@id}"
    @url ||= "https://people.epfl.ch/cgi-bin/getCoursData/?sciper=#{@id}"
  end
end
