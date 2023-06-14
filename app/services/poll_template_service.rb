class PollTemplateService
  def self.group_templates(group: , default_format: 'html')
    group.poll_templates.to_a.concat(
      default_templates.map do |template|
        template.position = group.poll_template_positions[template.key]
        template.details_format = default_format
        template.process_introduction_format = default_format
        template.group_id = group.id
        template.discarded_at = DateTime.now if group.hidden_poll_templates.include?(template.key)
        template
      end
    )
  end

  def self.default_templates
    AppConfig.poll_templates.map do |key, raw_attrs|
      raw_attrs[:key] = key
      attrs = {}

      AppConfig.poll_types[raw_attrs['poll_type']]['defaults'].each_pair do |key, value|
        if key.match /_i18n$/
          attrs[key.gsub(/_i18n$/, '')] = value.is_a?(Array) ? value.map {|v| I18n.t(v)} : I18n.t(value)
        else
          attrs[key] = value
        end
      end

      raw_attrs.each_pair do |key, value|
        if key.match /_i18n$/
          attrs[key.gsub(/_i18n$/, '')] = value.is_a?(Array) ? value.map {|v| I18n.t(v)} : I18n.t(value)
        else
          attrs[key] = value
        end
      end

      attrs['poll_options'] = raw_attrs.fetch('poll_options', []).map do |raw_option|
        option = {}
        raw_option.each_pair do |key, value|
          if key.match /_i18n$/
            option[key.gsub(/_i18n$/, '')] = I18n.t(value)
          else
            option[key] = value
          end
        end
        option
      end

      attrs['details_format'] = nil
      attrs['process_introduction_format'] = nil
      PollTemplate.new attrs
    end
  end

  def self.create(poll_template:, actor:)
    actor.ability.authorize! :create, poll_template

    poll_template.assign_attributes(author: actor)

    return false unless poll_template.valid?

    if poll_template.key
      poll_template.group.hidden_poll_templates += Array(poll_template.key)
      poll_template.key = nil
    end

    poll_template.save!
    poll_template
  end

  def self.update(poll_template:, params:, actor:)
    actor.ability.authorize! :update, poll_template

    poll_template.assign_attributes_and_files(params.except(:group_id))
    return false unless poll_template.valid?
    poll_template.save!

    poll_template
  end
end
