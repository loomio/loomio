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

  def self.group_templates(group: )
    group.discussion_templates.to_a.concat(
      default_templates.map do |template|
        template.position = group.discussion_template_positions.fetch(template.key, 999)
        template.group_id = group.id
        template.discarded_at = DateTime.now if group.hidden_discussion_templates.include?(template.key)
        template
      end
    )
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
    end
  end
end