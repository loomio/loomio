module Loomio
  module I18n

    SELECTABLE_LOCALES = %i( en be-BY bg-BG ca cs zh-TW de eo es el fr id it hu ja ko ml nl-NL pt-BR ro sr sr-RS sv vi tr uk )

    DETECTABLE_LOCALES = SELECTABLE_LOCALES + %i( be pt zh zh-HK )

    # only for display purposes, please don't depend on this in the system
    TEST_LOCALES = %i( ar cmn hr da fi gl ga-IE km mk mi fa-IR pl pt-PT ru sl te )

    FALLBACKS = { :ca      => :es,
                  :'pt-PT' => :'pt-BR',
                  :be      => :'be-BY',
                  :pt      => :'pt-BR',
                  :zh      => :'zh-TW',
                  :'zh-HK' => :'zh-TW'
                 }

    # for locales which are only serving as redirects, make sure to add to  :
    #   i) DETECTABLE_LOCALES
    #  ii) FALLBACKS
    # iii) a dummy yaml e.g. config/locales/fallback.zh-HK.yml
  end
end
