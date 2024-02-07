# frozen_string_literal: true

# This class represents a person as described by api.epfl.ch
class Person
  attr_reader :data, :position

  private_class_method :new

  # has one profile

  def initialize(person)
    Rails.logger.debug person
    @data = person
    @position = @data.delete('position')
    @position = Position.new(@position) unless @position.nil?

    # phones and addresses are hash with the unit_id as key
    @phones = (@data.delete('phones') || []).map { |d| Phone.new(d) }.group_by(&:unit_id)
    @addresses = (@data.delete('addresses') || []).map { |d| Address.new(d) }.group_by(&:unit_id)
  end

  def self.find(sciper_or_email)
    g = if sciper_or_email.is_a?(Integer) || sciper_or_email =~ /^\d{6}$/
          APIPersonGetter.for_sciper(sciper_or_email)
        else
          APIPersonGetter.for_email(sciper_or_email)
        end
    p = g.fetch!
    new(p)
  end

  def profile
    @profile = Profile.for_sciper(sciper) unless defined?(@profile)
    @profile
  end

  def can_edit_profile?
    unless defined?(@can_edit_profile)
      @can_edit_profile = begin
        a = APIAuthGetter.new(sciper).fetch
        a.any? { |d| d['status'] == 'active' }
      end
    end
    @can_edit_profile
  end

  def achieving_professor?
    unless defined?(@is_achieving_professor)
      aa = Authorisation.right_for_sciper(sciper, 'AAR.report.control')
      @is_achieving_professor = aa.any?(&:ok?)
    end
    @is_achieving_professor
  end

  def display_name
    @display_name ||= "#{firstnameusual || firstname} #{lastnameusual || lastname}"
  end

  def sciper
    id
  end

  def visible_phones(unit)
    @phones.present? ? @phones[unit].select(&:visible?) : []
  end

  def phones(unit)
    @phones[unit]
  end

  def addresses(unit)
    @addresses.key?(unit) ? @addresses[unit] : []
  end

  def address(unit)
    addresses(unit).first
  end

  def default_phone
    unless defined?(@default_phone)
      @default_phone = @phones.present? ? @phones.values.flatten.select(&:visible?).flatten.min : nil
    end
    @default_phone
  end

  # TODO: fix once the actual data is available in api
  def class_delegate?
    rand(1..10) == 1
  end

  # TODO: check errors on api calls and decide how to recover
  def accreds
    @accreds ||= begin
      # exclude accreditations that do not have the 'botweb' property
      pp = Authorisation.botweb_for_sciper(sciper).select(&:ok?).index_by(&:unit_id)
      all_accreds = Accreditation.for_sciper(sciper)
      visible_accreds = all_accreds.select { |a| pp.key?(a.unit_id.to_s) }
      # attach preferences from people (order, visibility)
      if (p = profile).present?
        ap = p.accred_prefs.index_by(&:unit_id)
        visible_accreds.each { |a| a.set_options(ap[a.unit_id]) if ap.key?(a.unit_id.to_s) }
      end
      visible_accreds
    end
  end

  def units
    @units ||= accreds.map(&:unit)
  end

  def positions
    @positions ||= accreds.map(&:position)
  end

  def student?
    accreds.any?(&:student?)
  end

  # TODO: see if it is possible to guess if person could be a teacher in order
  # to avoid useless requests to ISA.
  def possibly_teacher?
    accreds.any?(&:possibly_teacher?)
    accreds.map(&:position).compact.any?(&:possibly_teacher?)
  end

  # ----------------------------------------------------------------------------

  # Methods that are not explicitly defined are assumed to be keys of @data
  # Fields that are expected to be always present will except if not found
  def method_missing(key, *args, &blk)
    @data.key?(key.to_s) ? @data[key.to_s] : super
  end

  def respond_to_missing?(key, include_private = false)
    @data.key?(key.to_s) || super
  end

  # Optional fields when not present will get a nil value without failing
  %w[firstnameusual lastnameusual].each do |m|
    define_method m.to_sym do
      @data[m]
    end
  end
end

# {
#   "account": {
#     "gecos": "string",
#     "gid": 0,
#     "home": "string",
#     "shell": "string",
#     "uid": 0,
#     "username": "string"
#   },
#   "addresses": [
#     {
#       "address": "string",
#       "country": "string",
#       "fromdefault": 0,
#       "part1": "string",
#       "part2": "string",
#       "part3": "string",
#       "part4": "string",
#       "part5": "string",
#       "postal": {
#         "part1": "string",
#         "part2": "string",
#         "part3": "string",
#         "part4": "string",
#         "part5": "string"
#       },
#       "roomunitid": 0,
#       "type": "string",
#       "typerelatedid": 0,
#       "unitid": "string"
#     }
#   ],
#   "automap": {
#     "path": "string",
#     "protocol": "string",
#     "security": "string",
#     "server": "string"
#   },
#   "camipro": {
#     "biblioid": "string",
#     "cardid": "string",
#     "cardstatus": "string",
#     "emissiondate": "string",
#     "persstatus": "string",
#     "statedate": "string"
#   },
#   "display": "string",
#   "email": "string",
#   "firstname": "string",
#   "firstnameuc": "string",
#   "firstnameus": "string",
#   "firstnameusual": "string",
#   "gender": "string",
#   "id": "string",
#   "lastname": "string",
#   "lastnameuc": "string",
#   "lastnameus": "string",
#   "lastnameusual": "string",
#   "name": "string",
#   "nameus": "string",
#   "org": "string",
#   "phones": [
#     {
#       "fromdefault": 0,
#       "hidden": 0,
#       "id": 0,
#       "number": "string",
#       "order": 0,
#       "roomid": 0,
#       "roomname": "string",
#       "unitid": "string"
#     }
#   ],
#   "physemail": "string",
#   "position": {
#     "labelen": "string",
#     "labelfr": "string",
#     "labelinclusive": "string",
#     "labelxx": "string"
#   },
#   "rooms": [
#     {
#       "externalroomid": 0,
#       "fromdefault": 0,
#       "hidden": 0,
#       "id": 0,
#       "name": "string",
#       "order": 0,
#       "unitid": "string"
#     }
#   ],
#   "sciper": "string",
#   "sex": "string",
#   "status": "string",
#   "studies": [
#     {
#       "accredunitid": 0,
#       "branch1": "string",
#       "branch3": "string",
#       "matricule": "string",
#       "sciper": "string",
#       "studylevel": "string"
#     }
#   ],
#   "type": "string",
#   "uid": 0,
#   "upfirstname": "string",
#   "upname": "string",
#   "username": "string"
# }