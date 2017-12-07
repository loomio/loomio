class TranslationService
  extend LocalesHelper

  def self.create(model:, to:)
    from = supported_language_for(model.locale_field.to_s)
    to   = supported_language_for(to)

    translation = model.translations.find_by(language: to) ||
                  Translation.new(translatable: model, language: to, fields: {})

    model.class.translatable_fields.each do |field|
      translation.fields[field.to_s] ||= translator.translate(model.send(field), from: from, to: to)
    end if from && translation.valid?

    translation.tap(&:save)
  end

  def self.supported_language_for(from)
    (supported_languages & [
      from,
      normalize(from),
      strip_dialect(from),
      fallback_for(from)
    ]).first
  end

  def self.supported_languages
    @@supported_languages ||= Array(translator&.supported_language_codes)
  end

  def self.translator
    @@translator ||= BingTranslator.new(ENV['TRANSLATE_APP_KEY']) if ENV['TRANSLATE_APP_KEY']
  end
end
