require "google/cloud/translate"

class TranslationService
  extend LocalesHelper

  GOOGLE_LOCALES = %w[af sq am ar hy as ay az bm eu be bn bho bs bg ca ceb zh-CN zh zh-TW co hr cs da dv doi nl en eo et ee fil fi fr fy gl ka de el gn gu ht ha haw he iw hi hmn hu is ig ilo id ga it ja jv jw kn kk km rw gom ko kri ku ckb ky lo la lv ln lt lg lb mk mai mg ms ml mt mi mr mni-Mtei lus mn my ne no ny or om ps fa pl pt pa qu ro ru sm sa gd nso sr st sn sd si sk sl so es su sw sv tl tg ta tt te th ti ts tr tk ak uk ur ug uz vi cy xh yi yo zu]

  KNOWN_I18N_LABEL_KEYS = %w[
    poll_proposal_options.*
    poll_count_options.*
    poll_templates.*
    discussion_templates.*
  ]

  def self.show_translation(model, recipient)
    TranslationService.available? &&
    model.content_locale.present? &&
    model.content_locale != recipient.locale &&
    recipient.auto_translate
  end

  def self.plain_text(model, field, recipient)
    if show_translation(model, recipient)
      TranslationService.create(model: model, to: @recipient.locale).fields[String(field)]
    else
      model.send(field)
    end
  end

  def self.formatted_text(model, field, recipient)
    format_field = "#{field}_format"
    content_format = 'html'

    content = if show_translation(model, recipient)
      translation = TranslationService.create(model: model, to: recipient.locale)
      translation.fields[String(field)]
    else
      content_format = 'md' if model.send("#{field}_format") == "md"
      model.send(field)
    end

    MarkdownService.render_rich_text(content, content_format)
  end


  def self.flatten_i18n_keys(obj, prefix)
    case obj
    when Hash
      obj.flat_map { |k, v| flatten_i18n_keys(v, "#{prefix}.#{k}") }
    else
      [prefix]
    end
  end

  def self.expand_known_i18n_keys(locale)
    base_locale = locale.to_s.split(/[-_]/).first.presence || 'en'
    KNOWN_I18N_LABEL_KEYS.flat_map do |pattern|
      if pattern.include?('*')
        scope = pattern.sub(/\.?\*+$/, '')
        base = I18n.t(scope, locale: base_locale, default: {})
        if base.is_a?(Hash)
          flatten_i18n_keys(base, scope)
        else
          []
        end
      else
        [pattern]
      end
    end.uniq
  end

  def self.locale_for_google(locale)
    locale = locale.to_s.downcase.gsub("_", "-")
    return locale if GOOGLE_LOCALES.include?(locale)
    locale.split("-")[0]
  end

  def self.find_i18n_translation(value, from:, to:)
    return nil if value.blank?
    val = value.to_s.strip
    from_locale = from.to_s.split(/[-_]/).first.presence || 'en'
    to_locale = to.to_s.split(/[-_]/).first.presence || 'en'

    expand_known_i18n_keys(from_locale).each do |key|
      from_text = I18n.t(key, locale: from_locale, default: nil)
      next if from_text.blank? || from_text.is_a?(Hash)
      if from_text.to_s.strip == val
        to_text = I18n.t(key, locale: to_locale, default: nil)
        return to_text if to_text.present? && !to_text.is_a?(Hash)
      end
    end

    nil
  end

  def self.translated_fields_for(model, to:)
    service = Google::Cloud::Translate.translation_v2_service
    fields = {}
    from_locale = if model.respond_to?(:content_locale) && model.content_locale.present?
      model.content_locale
    else
      I18n.locale.to_s
    end

    model.class.translatable_fields.each do |field|
      content = model.send(field)

      translate_options = { to: to, format: :text }

      if content.blank?
        fields[field.to_s] = nil
        next
      end

      if (known = find_i18n_translation(content, from: from_locale, to: to))
        fields[field.to_s] = known
        next
      end

      format_field = "#{field}_format"

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
