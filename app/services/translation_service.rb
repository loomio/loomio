class TranslationService

  def self.create(model:, to:)
    translation = model.translations.find_by(language: to) ||
                  Translation.new(translatable: model, language: to, fields: {})

    model.class.translatable_fields.each do |field|
      translation.fields[field.to_s] ||= translator.translate(model.send(field), from: model.locale_field, to: to)
    end if translation.valid?

    translation.tap(&:save)
  end

  def self.app_key
    ENV['TRANSLATE_APP_KEY']
  end

  def self.translator
    @@translator ||= BingTranslator.new(app_key)
  end

  def self.supported_languages
    @@supported_languages ||= if app_key.present?
      translator.supported_language_codes
    else
      []
    end
  end
end
