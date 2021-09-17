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
      text.gsub!('](/rails/active_storage', ']('+lmo_asset_host+'/rails/active_storage')
      markdownify(text)
    else
      text.gsub!('"/rails/active_storage', '"'+lmo_asset_host+'/rails/active_storage')
      replace_iframes(text)
    end.html_safe
  end

  def render_plain_text(text, format = 'md')
    return "" unless text
    ActionController::Base.helpers.strip_tags(render_rich_text(text, format)).gsub(/(?:\n\r?|\r\n?)/, '<br>')
  end

  def replace_iframes(str)
    srcs = Nokogiri::HTML(str).search("iframe[src]").map { |el| el['src'] }
    out = str.dup
    srcs.each do |src|
      begin
        vi = VideoInfo.new(src)
        out.gsub!('<iframe src="'+src+'"></iframe>', "<a href='#{vi.url}'><img src='#{vi.thumbnail}' /></a>")
      rescue # yea, there are stupid errors to collect here.
        out.gsub!('<iframe src="'+src+'"></iframe>', "<a href='#{src}'>#{src}</a>")
      end
    end
    out
  end

  def markdownify(text)
    renderer = LoomioMarkdown.new(filter_html: true, hard_wrap: true, link_attributes: {rel: "nofollow ugc noreferrer noopener", target: :_blank})
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
    return nil unless user.is_logged_in?
    return nil unless model.discussion_id
    "\"#{I18n.transliterate(model.discussion.group.full_name).truncate(50).delete('"')}\" <#{reply_to_address(model: model, user: user)}>"
  end

  def mark_summary_as_read_url_for(user, format: nil)
     email_actions_mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                                  time_start: @time_start.utc.to_i,
                                                  time_finish: @time_finish.utc.to_i,
                                                  format: format)
  end

  def google_pie_chart_url(poll)
    CGI.escape("https://chart.googleapis.com/chart?cht=p&chma=0,0,0,0|0,0&chs=200x200&chd=t:#{proposal_sparkline(poll)}&chco=#{proposal_colors(poll)}")
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
      poll.poll_options.map {|option| option.color.gsub('#', '') }.join('|')
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
