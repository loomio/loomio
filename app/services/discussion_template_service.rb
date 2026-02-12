class DiscussionTemplateService
  def self.create(discussion_template:, actor:)
    actor.ability.authorize! :create, discussion_template

    discussion_template.assign_attributes(author: actor)

    return false unless discussion_template.valid?

    if discussion_template.key
      discussion_template.group.hidden_discussion_templates += Array(discussion_template.key)
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

  def self.initial_templates(category, parent_id)
    fallbacks = parent_id ? ['blank'] : ['blank', 'practice_thread']

    names = {
      board:         ['blank', 'discuss_a_topic', 'practice_thread', 'approve_a_document', 'prepare_for_a_meeting', 'funding_decision'],
      membership:    ['blank', 'discuss_a_topic', 'practice_thread', 'share_links_and_info', 'decision_by_consensus', 'elect_a_governance_position'],
      self_managing: ['blank', 'discuss_a_topic', 'practice_thread', 'advice_process', 'consent_process'],
      other:         ['blank', 'discuss_a_topic', 'practice_thread', 'approve_a_document', 'advice_process', 'consent_process'],
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
