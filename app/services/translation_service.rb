require "google/cloud/translate"

class TranslationService
  extend LocalesHelper

  def self.create(model:, to:)
    translation = model.translations.find_by(language: to) ||
                  Translation.new(translatable: model, language: to, fields: {})

    if translation.new_record? || ((translation.updated_at || translation.created_at) < (model.updated_at || model.created_at || 5.years.ago))
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

  def self.translate_group_content!(group, locale, cache_only = false)
    group.discussions.each do |discussion|
      translate_group_record(group, discussion, locale, cache_only)
    end

    group.polls.each do |poll|
      translate_group_record(group, poll, locale, cache_only)

      poll.poll_options.each do |poll_option|
        if poll.poll_option_name_format != 'plain'
          translate_group_record(group, poll_option, locale, cache_only, ignore: 'name')
        else
          translate_group_record(group, poll_option, locale, cache_only)
        end
      end

      poll.stances.each do |stance|
        translate_group_record(group, stance, locale, cache_only)
      end
    end

    group.comments.each do |comment|
      translate_group_record(group, comment, locale, cache_only)
    end
  end

  def self.translate_group_record(group, record, locale, cache_only = false, ignore: [])
    translate_record = if source_record_id = group.info.dig('source_record_ids', "#{record.class.to_s}-#{record.id}")
      record.class.find(source_record_id)
    else
      record
    end

    translation = TranslationService.create(model: translate_record, to: locale)

    return if cache_only

    translation.fields.each do |pair|
      next if ignore.include?(pair[0])
      record.update_attribute(pair[0], pair[1])
    end
  end
end
