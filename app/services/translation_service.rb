class TranslationService
  def initialize(translator = BingTranslator.new(ENV.fetch('BING_TRANSLATE_APPID', nil), ENV.fetch('BING_TRANSLATE_SECRET', nil)))
    @translator = translator
    raise TranslationUnavailableError.new unless self.class.available?
  end

  def translate(model, to: I18n.locale)
    translation = model.translations.find_by(language: to) ||
                  Translation.new(translatable: model, language: to, fields: {})

    model.class.translatable_fields.each do |field|
      translation.fields[field.to_s] ||= @translator.translate(model.send(field), from: model.locale_field, to: to)
    end if translation.valid?

    translation.tap(&:save)
  end

  def self.available?
    ENV.fetch('BING_TRANSLATE_APPID', nil) &&
    ENV.fetch('BING_TRANSLATE_SECRET', nil) &&
    true # don't return the secret!
  end

end

class TranslationUnavailableError < StandardError
  def to_s
    "Unable to instantiate BingTranslator: Please ensure that the ENV variables 'BING_TRANSLATE_APPID' and 'BING_TRANSLATE_SECRET' are set"
  end
end