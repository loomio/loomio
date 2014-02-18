class TranslationService
  def initialize(translator = BingTranslator.new(ENV.fetch('BING_TRANSLATE_APPID', nil), ENV.fetch('BING_TRANSLATE_SECRET', nil)))
    @translator = translator
    raise TranslationUnavailableError.new unless self.class.available?
  end
  
  def translate(model, to: I18n.locale)
    if model.translations.to_language(to).exists?
      translation = model.translations.to_language(to).first
    else
      translation = Translation.new translatable: model, language: to, fields: {}
    end
    
    model.class.translatable_fields.each do |field|
      translation.fields[field.to_s] ||= @translator.translate(model.send(field), from: model.language_field, to: to)
    end
    translation.save
    translation
  end

  def self.available?
    ENV.fetch('BING_TRANSLATE_APPID', nil) && 
    ENV.fetch('BING_TRANSLATE_SECRET', nil) &&
    true # don't return the secret!
  end
  
  def self.can_translate?(translatable)
    self.available? && translatable.language_field != I18n.locale.to_s
  end

end

class TranslationUnavailableError < StandardError
  def to_s
    "Unable to instantiate BingTranslator: Please ensure that the ENV variables 'BING_TRANSLATE_APPID' and 'BING_TRANSLATE_SECRET' "
  end
end