module Loomio
  module I18n
    LANGUAGES = { 'English' => :en,
                  'беларуская мова ' => :'be-BY',
                  'български' => :'bg-BG',
                  'Català' => :ca,
                  'čeština' => :cs,
                  '正體中文' => :'zh-TW', #zh-Hant, Chinese (traditional), Taiwan
                  'Deutsch' => :de,
                  'Español' => :es,
                  'Esperanto' => :eo,
                  'ελληνικά' => :el,
                  'Français' => :fr,
                  'Indonesian' => :id,
                  'Italiano' => :it,
                  'magyar' => :hu,
                  '日本語' => :ja,
                  '한국어' => :ko,
                  'മലയാളം' => :ml,
                  'Nederlands' => :'nl-NL',
                  'Português (Brasil)' => :'pt-BR',
                  'română' => :ro,
                  'Srpski - Latinica' => :sr,
                  'Srpski - Ćirilica' => :'sr-RS',
                  'Svenska' => :sv,
                  'Tiếng Việt' => :vi,
                  'Türkçe' => :tr,
                  'українська мова' => :uk }

    LOCALE_FALLBACKS = { :be => :'be-BY',
                         :ca => :es,
                         :pt => :'pt-BR',
                         :'pt-PT' => :'pt-BR',
                         :zh => :'zh-TW' }

    EXPERIMENTAL_LOCALE_STRINGS = %w( ar cmn hr da eo fi gl ga-IE km mk mi fa-IR pl pt-PT ru sl te )

  end
end
