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
    discussion_template
  end


  def self.update(discussion_template:, params:, actor:)
    actor.ability.authorize! :update, discussion_template

    discussion_template.assign_attributes_and_files(params.except(:group_id))
    return false unless discussion_template.valid?
    discussion_template.save!

    discussion_template
  end

  def self.initial_templates(category)
    names = {
      board:         ['blank', 'onboarding_to_loomio', 'discuss_a_topic', 'approve_a_document', 'prepare_for_a_meeting'],
      community:     ['blank', 'onboarding_to_loomio', 'discuss_a_topic', 'decision_by_consensus', 'share_links_and_info'],
      coop:          ['blank', 'onboarding_to_loomio', 'discuss_a_topic', 'consent_process', 'share_links_and_info'],
      membership:    ['blank', 'onboarding_to_loomio', 'discuss_a_topic'],
      nonprofit:     ['blank', 'onboarding_to_loomio', 'discuss_a_topic'],
      party:         ['blank', 'onboarding_to_loomio', 'discuss_a_topic'],
      professional:  ['blank', 'onboarding_to_loomio', 'discuss_a_topic'],
      self_managing: ['blank', 'onboarding_to_loomio', 'discuss_a_topic'],
      union:         ['blank', 'onboarding_to_loomio', 'discuss_a_topic'],
    }.with_indifferent_access.fetch(category, ['blank'])

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
      group.creator = User.helper_bot
      group.name = 'Loomio Templates'
      group.is_visible_to_public = false
      group.logo.attach(io: URI.open(Rails.root.join('public/brand/icon_gold_256h.png')),
                        filename: 'loomiologo.png')
    end

    group.discussion_templates = default_templates.map do |dt| 
      dt.public = true
      dt.author = User.helper_bot
      dt
    end
  end
end