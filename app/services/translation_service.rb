require "google/cloud/translate"

class TranslationService
  extend LocalesHelper

  def self.create(model:, to:)
    translation = model.translations.find_by(language: to) ||
                  Translation.new(translatable: model, language: to, fields: {})

    service = Google::Cloud::Translate.translation_v2_service

    model.class.translatable_fields.each do |field|
      translation.fields[field.to_s] = service.translate(model.send(field), to: to)
    end

    translation.tap(&:save)
  end

  def self.available?
    ENV['TRANSLATE_CREDENTIALS'].present?
  end
end
