class Translation
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
               'മലയാളം' => 'ml',
               'Nederlands' => 'nl',
               'Português (Brasil)' => 'pt',
               'română' => 'ro',
               'Tiếng Việt' => 'vi'}

  EXPERIMENTAL_LANGUAGES = {'Italiano' => 'it',
                            'తెలుగు' => 'te',
                            'Gaelic (Irish)' => 'ga',
                            'Türkçe' => 'tr'}

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
