class AppTranslation
  LANGUAGES = {'English' => :en,
               'български' => :bg,
               'Català' => :ca,
               'čeština' => :cs,
               '正體中文' => :zh, #zh-Hant, Chinese (traditional), Taiwan
               'Deutsch' => :de,
               'Español' => :es,
               'ελληνικά' => :el,
               'Français' => :fr,
               'Indonesian' => :id,
               'magyar' => :hu,
               '日本語' => :ja,
               '한국어' => :ko,
               'മലയാളം' => :ml,
               'Nederlands' => :nl,
               'Português (Brasil)' => :pt,
               'română' => :ro,
               'srpski' => :sr,
               'Svenska' => :sv,
               'Tiếng Việt' => :vi,
               'Türkçe' => :tr,
               'українська мова' => :uk}

  EXPERIMENTAL_LANGUAGES = {'Chinese (Mandarin)' => :cmn,
                            'Italiano' => :it,
                            'తెలుగు' => :te,
                            'Gaelic (Irish)' => :ga,
                            'Esperanto' => :eo,
                            'Telugu' => :te,
                            'khmer' => :km}

  FRONTPAGE_SUPPORTED_LOCALES = [:en, :pt, :el, :es, :ca, :cs, :fr, :uk, :nl, :zh, :sv, :da, :be, :ru, :ko, :sr]

  VIDEO_SUPPORTED_LOCALES  = [:en, :pt, :el, :es, :ca, :cs, :fr, :ja, :nl, :vi]
  
  def self.language(locale)
    LANGUAGES.key(locale.to_sym)
  end

  def self.locales
    LANGUAGES.values
  end

  def self.locale_strings
    LANGUAGES.values.map(&:to_s)
  end

  def self.frontpage_locales
    FRONTPAGE_SUPPORTED_LOCALES
  end

  def self.video_locales
    VIDEO_SUPPORTED_LOCALES
  end

  def self.experimental_locales
    EXPERIMENTAL_LANGUAGES.values
  end

  def self.permitted_locale?(locale)
    return false if locale.blank?
    (LANGUAGES.values + EXPERIMENTAL_LANGUAGES.values).include? locale.to_sym
  end

  def self.language_link_attributes(language)
    { href: "?&locale=#{language[1]}"  ,
      title: "#{I18n.t(:change_language, language: language[0])}",
      text: "#{language[0]}" }
  end

end
