class RecipeService
  def self.find_or_create(url:)
    @recipe = Recipe.find_by(url: url)
    return @recipe if @recipe
    create(url: url)
  end
  
	def self.create(url:)
    response = HTTParty.get(url)
    return nil if response.code != 200

    body = response.body

    @recipe = Recipe.create(url: url, body: body)
    @recipe
	end

  def self.export_discussion(d)
    str = hash_to_html(discussion_to_hash(d), 'thread')
    d.polls.each do |p|
      str << hash_to_html(poll_to_hash(p), 'poll')
    end
    str
  end

  def self.hash_to_html(h, kind)
    str = "<table data-loomio-#{kind}>\n"
    first = true

    h.each_pair do |key, value|
      safe_value = CGI.escapeHTML(value.to_s)
      if first
        first = false
        str << "<tr><th>#{key}</th><th>#{safe_value}</th></tr>\n"
      else
        str << "<tr><td>#{key}</td><td>#{safe_value}</td></tr>\n"
      end
    end
    str += "</table>\n"
    str.html_safe
  end

  def self.discussion_to_hash(d)
    vals = {}
    vals['Thread fields'] = 'values'
    fields = {
      title: nil,
      description: nil,
      description_format: nil,
      newest_first: false
    }

    fields.each_pair do |field, default|
      next if d.send(field) == default
      vals[field] = d.send(field)
    end
    vals
  end

  def self.poll_to_hash(p)
    vals = {}
    vals['Poll fields'] = 'values'

    fields = %w[
      title
      poll_type
      process_name
      process_subtitle
      details
      details_format
      default_duration_in_days
      anonymous
      hide_results
      specified_voters_only
      notify_on_closing_soon
      shuffle_options
      allow_long_reason
      min_score
      max_score
      minimum_stance_choices
      maximum_stance_choices
      dots_per_person
      reason_prompt
      poll_option_name_format
      stance_reason_required
    ]

    fields.each do |field|
      next if p.send(field).blank?
      next if p.send(field) == AppConfig.poll_types.dig(p.poll_type, 'defaults', field)
      vals[field] = p.send(field)
    end

    p.poll_options.each do |option|
      ['name', 'icon', 'reason_prompt', 'meaning'].each do |field|
        next if option[field].blank?
        # consier how to remove values if they're just defaults anyway
        vals["option#{option.priority} #{field}"] = option[field]
      end
    end
    vals
  end
end