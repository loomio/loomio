require "google/cloud/translate"

class TranslationService
  extend LocalesHelper

  def self.create(model:, to:)
    to   = supported_language_for(to)

    translation = model.translations.find_by(language: to) ||
                  Translation.new(translatable: model, language: to, fields: {})

    model.class.translatable_fields.each do |field|
      translation.fields[field.to_s] ||= translator.translate(model.send(field), to: to)
    end if to

    translation.tap(&:save)
  end

  def self.supported_language_for(lang)
    (AppConfig.translate_languages & [
      lang,
      normalize(lang),
      strip_dialect(lang),
      fallback_for(lang)
    ]).first
  end

  def self.translator
    @@translator ||= Google::Cloud::Translate.new if ENV['GOOGLE_CLOUD_KEY']
  end
end
