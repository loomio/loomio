class DiscussionTemplateService
  def self.create(discussion_template:, actor:)
    actor.ability.authorize! :create, discussion_template

    discussion_template.assign_attributes(author: actor)

    return false unless discussion_template.valid?

    if discussion_template.key
      group = discussion_template.group
      group.hidden_discussion_templates = group.hidden_discussion_templates | Array(discussion_template.key)
      group.save!
      discussion_template.key = nil
    end

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
    ensure_hidden_initialized(group)
    group.discussion_templates.to_a.concat(
      initial_templates(group.category, group.parent_id).map do |template|
        template.position = group.discussion_template_positions.fetch(template.key, 999)
        template.group_id = group.id
        template.discarded_at = DateTime.now if group.hidden_discussion_templates.include?(template.key)
        template
      end
    )
  end

  def self.ensure_hidden_initialized(group)
    return if group[:info].key?('hidden_discussion_templates')
    keys = initial_templates(group.category, group.parent_id).map(&:key) - VISIBLE_BY_DEFAULT
    group[:info]['hidden_discussion_templates'] = keys
    group.save!
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

  def self.create_public_templates
    group = Group.find_or_create_by(handle: 'templates') do |group|
      group.creator = User.first
      group.name = 'Loomio Templates'
      group.is_visible_to_public = false
    end

    group.discussion_templates = default_templates.map do |dt|
      dt.public = true
      dt
    end
  end
end
