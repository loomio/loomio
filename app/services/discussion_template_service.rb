class DiscussionTemplateService
  def self.create(discussion_template:, actor:)
    actor.ability.authorize! :create, discussion_template

    discussion_template.assign_attributes(author: actor)

    return false unless discussion_template.valid?

    discussion_template.key = nil if discussion_template.key
    discussion_template.save!
    discussion_template.discard! unless discussion_template.group.admins.exists?(actor.id)
    discussion_template
  end


  def self.update(discussion_template:, params:, actor:)
    actor.ability.authorize! :update, discussion_template

    discussion_template.assign_attributes_and_files(params.except(:group_id))
    return false unless discussion_template.valid?
    discussion_template.save!

    discussion_template
  end

  VISIBLE_BY_DEFAULT = %w[blank practice_thread].freeze

  def self.group_templates(group:)
    ensure_templates_materialized(group)
    group.discussion_templates.order(:position)
  end

  def self.ensure_templates_materialized(group)
    return if group.discussion_templates.exists?

    group.with_lock do
      return if group.discussion_templates.exists?

      hidden_keys = if group[:info].key?('hidden_discussion_templates')
        group[:info]['hidden_discussion_templates'] || []
      else
        initial_templates(group.category, group.parent_id).map(&:key) - VISIBLE_BY_DEFAULT
      end

      positions = group[:info]['discussion_template_positions'] || {}

      initial_templates(group.category, group.parent_id).each do |template|
        dt = group.discussion_templates.create!(
          key: template.key,
          process_name: template.process_name,
          process_subtitle: template.process_subtitle,
          process_introduction: template.process_introduction,
          process_introduction_format: template.process_introduction_format,
          title: template.title,
          title_placeholder: template.title_placeholder,
          description: template.description,
          description_format: template.description_format,
          tags: template.tags || [],
          max_depth: template.max_depth,
          newest_first: template.newest_first,
          poll_template_keys_or_ids: template.poll_template_keys_or_ids || [],
          recipient_audience: template.recipient_audience,
          default_to_direct_discussion: template.default_to_direct_discussion || false,
          position: positions.fetch(template.key, 999)
        )
        dt.discard! if hidden_keys.include?(template.key)
      end
    end
  end

  def self.initial_templates(category, parent_id)
    fallbacks = parent_id ? ['blank'] : ['blank', 'practice_thread']

    names = {
      board:         ['blank', 'practice_thread', 'approve_a_document', 'prepare_for_a_meeting', 'funding_decision'],
      membership:    ['blank', 'practice_thread', 'share_links_and_info', 'decision_by_consensus', 'elect_a_governance_position'],
      self_managing: ['blank', 'practice_thread', 'advice_process', 'consent_process'],
      other:         ['blank', 'practice_thread', 'approve_a_document', 'advice_process', 'consent_process'],
    }.with_indifferent_access.fetch(category, fallbacks)

    default_templates.filter { |dt| names.include? dt.key }
  end

  def self.default_templates
    AppConfig.discussion_templates.map do |key, raw_attrs|
      raw_attrs[:key] = key
      attrs = {}

      raw_attrs.each_pair do |key, value|
        if key.match /_i18n$/
          attrs[key.gsub(/_i18n$/, '')] = value.is_a?(Array) ? value.map {|v| I18n.t(v)} : I18n.t(value)
        else
          attrs[key] = value
        end
      end

      DiscussionTemplate.new attrs
    end.reverse
  end
end
