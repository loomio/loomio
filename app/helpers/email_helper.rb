module EmailHelper
  include PrettyUrlHelper

  MARKDOWN_OPTIONS = [
    no_intra_emphasis:    true,
    tables:               true,
    fenced_code_blocks:   true,
    autolink:             true,
    strikethrough:        true,
    space_after_headers:  true,
    superscript:          true,
    underline:            true
  ].freeze

  def stance_icon_for(poll, stance_choice)
    case stance_choice&.score.to_i
      when 0 then "disagree"
      when 1 then "abstain"
      when 2 then "agree"
    end if poll.has_score_icons
  end

  def render_rich_text(text, format = "md")
    return "" unless text
    if format == "md"
      Redcarpet::Render::SmartyPants.render(emojify(markdownify(text))).html_safe
    else
      text.html_safe
    end
  end

  def render_rich_text_fast(text, format = "md")
    return "" unless text
    if format == "md"
      markdownify(text).html_safe
    else
      text.html_safe
    end
  end

  def emojify(text)
    Emojifier.emojify!(text)
  end

  def markdownify(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true, link_attributes: {target: :_blank})
    Redcarpet::Markdown.new(renderer, *MARKDOWN_OPTIONS).render(text)
  end

  def reply_to_address(model:, user: )
    address = {
      c: (model.id if model.is_a?(Comment)),
      d: model.discussion_id,
      u: user.id,
      k: user.email_api_key
    }.compact.map { |k, v| [k,v].join('=') }.join('&')
    [address, ENV['REPLY_HOSTNAME']].join('@')
  end

  def reply_to_address_with_group_name(model:, user:)
    return unless user.is_logged_in?
    "\"#{model.discussion.group.full_name}\" <#{reply_to_address(model: model, user: user)}>"
  end

  def render_email_plaintext(text)
    Rinku.auto_link(simple_format(html_escape(text)), :all, 'target="_blank"').html_safe
  end

  def mark_summary_as_read_url_for(user, format: nil)
     email_actions_mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                                  time_start: @time_start.utc.to_i,
                                                  time_finish: @time_finish.utc.to_i,
                                                  format: format)
  end

  def formatted_time_in_zone(time, zone)
    return unless time && zone
    time.in_time_zone(TimeZoneToCity.convert zone).strftime('%l:%M%P - %A %-d %b %Y')
  end

  def google_pie_chart_url(poll)
    URI.escape("https://chart.googleapis.com/chart?cht=p&chma=0,0,0,0|0,0&chs=200x200&chd=t:#{proposal_sparkline(poll)}&chco=#{proposal_colors(poll)}")
  end

  def proposal_sparkline(poll)
    if poll.stance_counts.max.to_i > 0
      poll.stance_counts.join(',')
    else
      '1'
    end
  end

  def proposal_colors(poll)
    if poll.stance_counts.max.to_i > 0
      AppConfig.colors.fetch(poll.poll_type, []).map { |color| color.sub('#', '') }.join('|')
    else
      'aaaaaa'
    end
  end

  def percentage_for(poll, index)
    if poll.stance_counts.max.to_i > 0
      (100 * poll.stance_counts[index].to_f / poll.stance_counts.max).to_i
    else
      0
    end
  end

  def dot_vote_stance_choice_percentage_for(stance, stance_choice)
    max = stance.poll.dots_per_person.to_i
    if max > 0
      (100 * stance_choice.score.to_f / max).to_i
    else
      0
    end
  end

  def score_stance_choice_percentage_for(stance, stance_choice)
    max = stance.poll.max_score.to_i
    if max > 0
      (100 * stance_choice.score.to_f / max).to_i
    else
      0
    end
  end
end
