module Loomio
  module I18n

    SELECTABLE_LOCALES = %i( en be-BY bg-BG ca cs zh-TW de eo es el fr id it hu ja ko ml nl-NL pt-BR ro sr sr-RS sv vi tr uk )

    DETECTABLE_LOCALES = SELECTABLE_LOCALES + %i( be pt zh )

    # only for display purposes, please don't depend on this in the system
    TEST_LOCALE_STRINGS = %i( ar cmn hr da fi gl ga-IE km mk mi fa-IR pl pt-PT ru sl te )

    FALLBACKS = { :ca      => :es,
                  :'pt-PT' => :'pt-BR',
                  :be      => :'be-BY',
                  :pt      => :'pt-BR',
                  :zh      => :'zh-TW'
                 }
  end
end
