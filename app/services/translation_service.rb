require "google/cloud/translate"

class TranslationService
  extend LocalesHelper

  def self.create(model:, to:)
    translation = model.translations.find_by(language: to) ||
                  Translation.new(translatable: model, language: to, fields: {})

    if translation.new_record? || ((translation.updated_at || translation.created_at) < (model.updated_at || model.created_at || DateTime.now))
      service = Google::Cloud::Translate.translation_v2_service

      model.class.translatable_fields.each do |field|
        next if model.send(field).blank?
        translation.fields[field.to_s] = service.translate(model.send(field), to: to)
      end

      translation.save!
    end

    translation
  end

  def self.available?
    ENV['TRANSLATE_CREDENTIALS'].present?
  end
end
