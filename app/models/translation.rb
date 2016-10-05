class Translation < ActiveRecord::Base
  # This is the output from BingTranslator.new.supported_language_codes
  # However, that method makes an expensive external API call
  # so we don't want to do it every request

  # TODO: Write a job which runs occasionally to fetch and store this info locally.
  # This list is current as of Oct 2016.
  SUPPORTED_LANGUAGES = [
    "af", "ar", "bs-Latn", "bg", "ca",
    "zh-CHS", "zh-CHT", "yue", "hr", "cs",
    "da", "nl", "en", "et", "fi",
    "fr", "de", "el", "ht", "he",
    "hi", "mww", "hu", "id", "it",
    "ja", "sw", "tlh", "tlh-Qaak", "ko",
    "lv", "lt", "ms", "mt", "yua",
    "no", "otq", "fa", "pl", "pt",
    "ro", "ru", "sr-Cyrl", "sr-Latn", "sk",
    "sl", "es", "sv", "th", "tr",
    "uk", "ur", "vi", "cy"
  ].freeze

  belongs_to :translatable, polymorphic: true
  scope :to_language, ->(language) { where(language: language) }

  validates_presence_of :translatable, :language
  validates_inclusion_of :language, in: SUPPORTED_LANGUAGES

  # TODO: Should probably move to a serializer
  def as_json
    { id: translatable_id }.merge(fields)
  end
end
