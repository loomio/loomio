class PollTemplateService
  def self.default_poll_templates(default_format: 'html', group: )
    AppConfig.poll_templates.map do |key, raw_attrs|
      raw_attrs[:key] = key
      attrs = {}

      attrs['details_format'] = default_format

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

      if group.hidden_poll_templates.include?(key)
        attrs[:discarded_at] = DateTime.now
      end

      PollTemplate.new attrs
    end
  end

  def self.create(poll_template:, actor:)
    actor.ability.authorize! :create, poll_template

    poll_template.assign_attributes(author: actor)

    return false unless poll_template.valid?

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
