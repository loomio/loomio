class Translation < ActiveRecord::Base
  LANGUAGES = {'English' => 'en',
               'български' => 'bg',
               'Català' => 'ca',
               'čeština' => 'cs',
               'Deutsch' => 'de',
               'Español' => 'es',
               'ελληνικά' => 'el',
               'Français' => 'fr',
               'Indonesian' => 'id',
               'magyar' => 'hu',
               'Nederlands' => 'nl',
               'Português (Brasil)' => 'pt',
               'română' => 'ro',
               'Tiếng Việt' => 'vi'}

  EXPERIMENTAL_LANGUAGES = {'Italiano' => 'it',
                            'മലയാളം' => 'ml',
                            'తెలుగు' => 'te',
                            'Gaelic (Irish)' => 'ga'}

  belongs_to :translatable, polymorphic: true
  
  serialize :fields, ActiveRecord::Coders::Hstore
  
  scope :to_language, ->(language) { where(language: language) }

  validates_presence_of :translatable, :language
  
  def as_json
    { id: translatable_id }.merge(fields)
  end
  
  def self.language(locale)
    LANGUAGES.key(locale)
  end

  def self.locales
    LANGUAGES.values
  end

  def self.experimental_locales
    EXPERIMENTAL_LANGUAGES.values
  end

  def self.language_link_attributes(language)
    { href: "?&locale=#{language[1]}"  ,
      title: "#{I18n.t(:change_language, language: language[0])}",
      text: "#{language[0]}" }
  end
  
end
