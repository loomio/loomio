class Translation
  LANGUAGES = {"English" => "en", "Español" => "es", "ελληνικά" => "el", "magyar" => "hu", "română" => "ro"}

  def self.locales
    locales = []
    LANGUAGES.each do |language|
      locales << language[1]
    end
    locales
  end
end
