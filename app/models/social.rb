# frozen_string_literal: true

class Social < ApplicationRecord
  include AudienceLimitable

  RESEARCH_IDS = {
    # https://orcid.org/0000-0002-1825-0097
    'orcid' => {
      'img' => 'ORCIDiD_icon16x16.png',
      'url' => 'https://orcid.org/XXX',
      'label' => 'ORCID',
      'position' => 0,
      'icon' => nil,
      're' => /^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}$/,
      'help' => {
        'en' => 'https://orcid-integration.epfl.ch/',
        'fr' => 'https://orcid-integration.epfl.ch/'
      }
    },
    # https://www.webofscience.com/wos/author/rid/AAX-5119-2020
    'wos' => {
      'img' => 'publons.png',
      'url' => 'https://www.webofscience.com/wos/author/rid/XXX',
      'label' => 'Publons - Web of Science ID',
      'position' => 1,
      'icon' => nil,
      're' => /^([A-Z]+-[0-9]{4}-[0-9]{4}|[0-9])+$/
    },
    # https://www.scopus.com/authid/detail.uri?authorId=57192201516
    'scopus' => {
      'img' => 'scopus.png',
      'url' => 'https://www.scopus.com/authid/detail.uri?authorId=XXX',
      'label' => 'Scopus ID',
      'position' => 2,
      'icon' => nil,
      're' => /^[0-9]+$/
    },
    'googlescholar' => {
      'img' => 'google_scholar.png',
      'url' => 'https://scholar.google.com/citations?user=XXX&hl=en&oi=ao',
      # 'url' => "https://scholar.google.com/citations?user=XXX"
      'label' => 'Google Scholar ID',
      'position' => 3,
      'icon' => 'google',
      're' => /^[0-9a-zA-Z.-]+$/ # TODO: check this!
    },
    'linkedin' => {
      'img' => 'linkedin.jpg',
      'url' => 'https://www.linkedin.com/in/XXX',
      'label' => 'Linkedin ID',
      'position' => 4,
      'icon' => 'linkedin',
      're' => %r{^[a-z][a-z0-9-]+/?$} # TODO: check this!
    },
    # https://github.com/XXX
    'github' => {
      'img' => 'github.png',
      'url' => 'https://github.com/XXX',
      'label' => 'GitHub',
      'position' => 5,
      'icon' => 'github',
      're' => /^[A-Za-z0-9_.-]+$/,
    },
    'stack_overflow' => {
      'img' => 'stackoverflow.png',
      'url' => 'https://stackoverflow.com/users/XXX',
      'label' => 'Stack Overflow',
      'position' => 6,
      'icon' => 'stack-overflow',
      're' => /^[0-9]+$/
    },
    'mastodon' => {
      'img' => 'mastodon.png',
      'url' => 'https://mastodon.social/@XXX',
      'label' => 'Mastodon',
      'position' => 7,
      'icon' => 'mastodon',
      're' => /^[A-Za-z0-9_]+$/,
    },
    'facebook' => {
      'img' => 'facebook.png',
      'url' => 'https://www.facebook.com/XXX',
      'label' => 'Facebook',
      'position' => 8,
      'icon' => 'facebook',
      're' => /^[A-Za-z0-9.]+$/
    },
    'twitter' => {
      'img' => 'twitter.png',
      'url' => 'https://twitter.com/XXX',
      'label' => 'Twitter',
      'position' => 9,
      'icon' => 'twitter',
      're' => /^[A-Za-z0-9_]+$/
    },
    'instagram' => {
      'img' => 'instagram.png',
      'url' => 'https://www.instagram.com/XXX',
      'label' => 'Instagram',
      'position' => 10,
      'icon' => 'instagram',
      're' => /^[A-Za-z0-9._]+$/
    }
  }.freeze

  belongs_to :profile, class_name: "Profile", inverse_of: :socials

  validates :value, presence: true
  validates :tag, presence: true
  validates :tag, inclusion: { in: RESEARCH_IDS.keys }
  validate :validate_format_of_value

  before_save :ensure_sciper

  def self.for_sciper(sciper)
    where(sciper: sciper).order(:position)
  end

  def url
    @url ||= begin
      @s = RESEARCH_IDS[tag]
      @s['url'].sub('XXX', value)
    end
  end

  def icon_class
    @s ||= RESEARCH_IDS[tag]
    @s['icon'].nil? ? '' : "social-icon-#{@s['icon']}"
  end

  def icon
    @s ||= RESEARCH_IDS[tag]
    @s['icon']
  end

  def image
    @s ||= RESEARCH_IDS[tag]
    "social/#{@s['img']}"
  end

  def label
    @s ||= RESEARCH_IDS[tag]
    @s['label']
  end

  def default_position
    @s ||= RESEARCH_IDS[tag]
    @s['position']
  end

  private

  # we call this before save so that profile is present due to passed validation
  def ensure_sciper
    sciper || profile.sciper
  end

  def validate_format_of_value
    unless RESEARCH_IDS.key?(tag)
      errors.add(:tag, "Invalid social network name/tag")
      return false
    end
    re = RESEARCH_IDS[tag]['re']
    unless re.match?(value)
      errors.add(:value, "incorrect format")
      return false
    end
    true
  end

  def link_type_tag(url)
    RESEARCH_IDS.each_value do |value|
      return content_tag(:span, value['label'], class: 'tag tag-sm tag-primary') if url.match(value['re'])
    end
    content_tag(:span, 'Unknown', class: 'tag tag-sm tag-secondary')
  end
end
