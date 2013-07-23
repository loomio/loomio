class Translation
  LANGUAGES = {"български" => "bg",
               "English" => "en",
               "Español" => "es",
               "ελληνικά" => "el",
               "magyar" => "hu",
               "Nederlands" => "nl"}
  EXPERIMENTAL_LANGUAGES = {"română" => "ro"}

  def self.locales
    LANGUAGES.values
  end

  def self.experimental_locales
    EXPERIMENTAL_LANGUAGES.values
  end

  def self.language_links
    language_links = []
    LANGUAGES.each do |language|
      language_links << "<a href='?&locale=#{language[1]}'
                            title='#{I18n.t(:change_language, language: language[0])}'>
                            #{language[0]}</a>"
    end
    language_links << "<a href='https://www.loomio.org/discussions/4896'>#{I18n.t(:translate, default: "help translate Loomio!")}</a>"
    language_links.join(" &middot; ")
  end
end
