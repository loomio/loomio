class Translation
  LANGUAGES = {"English" => "en",
               "Español" => "es",
               "български" => "bg",
               "ελληνικά" => "el",
               "magyar" => "hu",
               "română" => "ro",
               "Nederlands" => "nl"}
  EXPERIMENTAL_LANGUAGES = {"Français" => "fr",
                            "Tiếng Việt" => "vi"}

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
