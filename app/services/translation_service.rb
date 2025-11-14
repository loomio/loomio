require "google/cloud/translate"

class TranslationService
  extend LocalesHelper

  GOOGLE_LOCALES = %w[af sq am ar hy as ay az bm eu be bn bho bs bg ca ceb zh-CN zh zh-TW co hr cs da dv doi nl en eo et ee fil fi fr fy gl ka de el gn gu ht ha haw he iw hi hmn hu is ig ilo id ga it ja jv jw kn kk km rw gom ko kri ku ckb ky lo la lv ln lt lg lb mk mai mg ms ml mt mi mr mni-Mtei lus mn my ne no ny or om ps fa pl pt pa qu ro ru sm sa gd nso sr st sn sd si sk sl so es su sw sv tl tg ta tt te th ti ts tr tk ak uk ur ug uz vi cy xh yi yo zu]

  def self.locale_for_google(locale)
    locale = locale.to_s.downcase.gsub("_", "-")
    return locale if GOOGLE_LOCALES.include?(locale)
    locale.split("-")[0]
  end

  def self.translated_fields_for(model, to:)
    service = Google::Cloud::Translate.translation_v2_service
    fields = {}

    model.class.translatable_fields.each do |field|
      value = model.send(field)

      if value.blank?
        fields[field.to_s] = nil
        next
      end

      format_field = "#{field}_format"
      content = value
      translate_options = { to: to, format: :text }

      if model.respond_to?(format_field)
        translate_options[:format] = :html
        if model.send(format_field) == 'md'
          content = MarkdownService.render_html(content)
        end
      end

      fields[field.to_s] = service.translate(content, **translate_options)
    end

    fields
  end



  def self.create(model:, to:)
    locale = locale_for_google(to)

    if translation = model.translations.find_by(language: locale)
      return translation
    end

    translation = Translation.new(translatable: model, language: locale, fields: {})
    translation.fields = translated_fields_for(model, to: locale)
    translation.save!
    translation
  end

  def self.update_and_broadcast(translatable_type, translatable_id)
    model = Object.const_get(translatable_type).find(translatable_id)



    Translation.where(translatable_type: translatable_type,
                      translatable_id: translatable_id).each do |translation|
      translation.fields = translated_fields_for(model, to: translation.language)
      translation.save!
      MessageChannelService.publish_models([translation], group_id: model.group_id)
    end
  end

  def self.available?
    ENV['TRANSLATE_CREDENTIALS'].present?
  end

  def self.translate_group_content!(group, locale, cache_only = false)
    return if locale == 'en'

    translate_group_record(group, group, locale, cache_only)

    group.discussions.each do |discussion|
      translate_group_record(group, discussion, locale, cache_only)
    end

    group.polls.each do |poll|
      translate_group_record(group, poll, locale, cache_only)

      poll.outcomes.each do |outcome|
        translate_group_record(group, outcome, locale, cache_only)
      end

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

    group.tags.each do |tag|
      translate_group_record(group, tag, locale, cache_only)
    end
  end

  def self.translate_group_record(group, record, locale, cache_only = false, ignore: [])
    translate_record = if source_record_id = group.info.dig('source_record_ids', "#{record.class}-#{record.id}")
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

    record.update_content_locale if record.has_attribute?(:content_locale)
  end
end
