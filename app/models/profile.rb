# frozen_string_literal: true

# Profile is the former _common_ table where we store most of the simple
# editable user's data.
# The read-only official data comes from external sources like
# accred & co. via api.epfl.ch and ISAcademia.

class Profile < ApplicationRecord
  # predefined primary key will brake testing when labels are used in fixtures
  # therefore, although I would much prefer to have sciper as the primary key,
  # I decided to abandon the idea in favor of ehnanced fixture readability.
  # I will probably duplicate sciper value in all models where it can be useful.
  # https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html
  # self.primary_key = 'sciper'

  include Translatable
  translates :nationality, :title

  has_many :boxes, dependent: :destroy
  has_many :socials, dependent: :destroy
  has_many :awards, dependent: :destroy
  has_many :educations, dependent: :destroy
  has_many :experiences, dependent: :destroy
  has_many :publications, dependent: :destroy

  accepts_nested_attributes_for :boxes, :socials, :awards, :educations, :experiences

  # TIP: avoid N+1 using with_attached_attachment helper:
  # @cv.with_attached_images.each do |cv|
  has_many :pictures, class_name: 'Picture', dependent: :destroy
  belongs_to :selected_picture, class_name: 'Picture',
                                optional: true, inverse_of: false
  belongs_to :camipro_picture, class_name: 'Picture',
                               optional: true, inverse_of: false

  has_many :accreds, class_name: 'Accred', dependent: :destroy
  # TODO: switch to new model

  # has_and_belongs_to_many :courses, join_table: "teacherships"
  has_many :teacherships, class_name: "Teachership", dependent: :destroy
  has_many :courses, through: :teacherships

  # TODO: add all presence validations. Translated properties should be present
  #       in at leat one of the languages when property is visible
  validates :sciper, uniqueness: { message: "must be unique" }

  after_create :cache_camipro_picture!

  DEFAULTS = {
    show_birthday: false,
    show_function: true,
    show_nationality: false,
    show_phone: true,
    show_photo: false,
    show_title: false,
    show_weburl: false,
    show_email: true,
    force_lang: nil,
    personal_web_url: nil,
    nationality_en: nil,
    nationality_fr: nil,
    title_en: nil,
    title_fr: nil,
    migrated: false,
  }.freeze

  def self.new_with_defaults(sciper)
    r = new(DEFAULTS.merge(sciper: sciper))
    return unless Rails.configuration.legacy_support

    clegacy = Legacy::Cv.find(sciper)
    ten_legacy = clegacy.translated_part('en')
    tfr_legacy = clegacy.translated_part('fr')
    r.show_birthday = clegacy.show_birthday?
    r.show_email = clegacy.show_email?
    r.show_nationality = clegacy.show_nationality?
    r.show_photo = clegacy.show_photo?
    r.personal_web_url = clegacy.web_perso
    r.show_weburl = clegacy.show_weburl?
    r.force_lang = clegacy.defaultcv if clegacy.defaultcv.present?
    # TODO: delegate edu_show, pub_show, tromb_show, parcours_show to corresponding boxes

    # TODO: eventually get rid of the title field (asked to Natalie for confirmation)
    r.title_en = ten_legacy.title if ten_legacy.title.present?
    r.title_fr = tfr_legacy.title if tfr_legacy.title.present?
    r.show_title = (ten_legacy.visible_title? || tfr_legacy.visible_title?)
    # TODO: delegate curriculum, expertise, mission to corresponding boxes
    r
  end

  def self.create_with_defaults(sciper)
    new_with_defaults(sciper).save
  end

  def self.for_sciper(sciper)
    # returns nil when nothing found
    where(sciper: sciper).first
  end

  def person
    @person ||= Person.find(sciper)
  end

  def photo
    show_photo ? photo! : nil
  end

  def photo!
    if selected_picture.present?
      selected_picture
    elsif camipro_picture.present?
      camipro_picture
    else
      cache_camipro_picture!
    end
  end

  # def camipro_picture
  #   pictures.camipro.first
  # end

  def any_publication?
    publications.present?
  end

  # TODO: Birthday is no long available in data from api. Get rid of it.
  def show_birthday?
    false
  end

  def birthday
    nil
  end

  def cache_camipro_picture!
    return if camipro_picture_id.present?

    cpp = pictures.create!(camipro: true)
    cpp.fetch
    self.camipro_picture_id = cpp.id
    self.selected_picture_id ||= cpp.id
    save!
    cpp
  end
end
