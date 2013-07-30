class Translation
  include ActionView::Helpers::TagHelper

  LANGUAGES = {"български" => "bg",
               "English" => "en",
               "Español" => "es",
               "ελληνικά" => "el",
               "magyar" => "hu",
               "Nederlands" => "nl"}
  EXPERIMENTAL_LANGUAGES = {"română" => "ro"}

  def self.language(locale)
    LANGUAGES.index(locale)
  end

  def self.locales
    LANGUAGES.values
  end

  def self.experimental_locales
    EXPERIMENTAL_LANGUAGES.values
  end

  def self.language_link(language)
    content_tag(:a, "#{language[0]}", href: "?&locale=#{language[1]}",
                title: "#{I18n.t(:change_language, language: language[0])}")
  end
end
