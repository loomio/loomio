require "google/cloud/translate"

module TranslationProviders
  class Google < Base
    SUPPORTED_LOCALES = %w[af sq am ar hy as ay az bm eu be bn bho bs bg ca ceb zh-CN zh zh-TW co hr cs da dv doi nl en eo et ee fil fi fr fy gl ka de el gn gu ht ha haw he iw hi hmn hu is ig ilo id ga it ja jv jw kn kk km rw gom ko kri ku ckb ky lo la lv ln lt lg lb mk mai mg ms ml mt mi mr mni-Mtei lus mn my ne no ny or om ps fa pl pt pa qu ro ru sm sa gd nso sr st sn sd si sk sl so es su sw sv tl tg ta tt te th ti ts tr tk ak uk ur ug uz vi cy xh yi yo zu]

    def self.available?
      ENV['TRANSLATE_CREDENTIALS'].present?
    end

    def translate(content, to:, format: :text)
      service = ::Google::Cloud::Translate.translation_v2_service
      service.translate(content, to: to, format: format)
    rescue ::Google::Cloud::ResourceExhaustedError
      raise TranslationService::QuotaExceededError, "Google quota exceeded"
    end

    def supported_languages
      SUPPORTED_LOCALES
    end

    def normalize_locale(locale)
      locale = locale.to_s.downcase.gsub("_", "-")
      return locale if SUPPORTED_LOCALES.map(&:downcase).include?(locale)
      locale.split("-")[0]
    end
  end
end
