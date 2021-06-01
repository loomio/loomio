module EmailHelper
  include Routing
  include PrettyUrlHelper

  def unfollow_url(discussion, action_name, recipient, new_volume: :quiet)
    args = utm_hash({discussion_id: discussion.id}, action_name)
    args = args.merge(unsubscribe_token: unsubscribe_token(recipient))
    args = args.merge(new_volume: new_volume)
    email_actions_unfollow_discussion_url(args)
  end

  def preferences_url(recipient, action_name)
    email_preferences_url(utm_hash({}, action_name).merge(unsubscribe_token: unsubscribe_token(recipient)))
  end

  def pixel_src(event, recipient)
    email_actions_mark_discussion_as_read_url(
      discussion_id:     event.eventable.discussion.id,
      event_id:          event.id,
      unsubscribe_token: recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def can_unfollow?(discussion, recipient)
    DiscussionReader.for(discussion: discussion, user: recipient).volume_is_loud?
  end

  def utm_hash(args = {}, action_name)
    {
      utm_medium: 'email',
      utm_campaign: 'discussion_mailer',
      utm_source: action_name
    }.merge(args)
  end

  def unsubscribe_token(recipient)
    recipient.unsubscribe_token || 'none'
  end

  def login_token(recipient, redirect_path)
    recipient.login_tokens.create!(redirect: redirect_path)
  end

  def recipient_stance(recipient, poll)
    poll.stances.latest.find_by(participant: recipient) || Stance.new(poll: poll, participant: recipient)
  end

  def time_zone(recipient, poll)
    recipient.time_zone || poll.time_zone
  end

  def formatted_time_zone(recipient, poll)
    time_zone = time_zone(recipient, poll)
    ActiveSupport::TimeZone[time_zone].to_s if time_zone
  end

  def choice_img(poll)
    prefix = poll.multiple_choice ? 'check' : 'radio'
    "poll_mailer/#{prefix}_off.png"
  end

  def target_url(poll: nil, eventable: nil, recipient:, args: {})
    if poll
      stance = recipient_stance(recipient, poll)
      args.merge!(stance_token: stance.token) if stance
      polymorphic_url(poll, poll_mailer_utm_hash.merge(args))
    else
      if discussion_reader = DiscussionReader.redeemable.find_by(user: recipient, discussion: eventable.discussion)
        args.merge!(discussion_reader_token: discussion_reader.token)
      end

      polymorphic_url(eventable, utm_hash(args))
    end
  end

  def unsubscribe_url(poll, recipient)
    poll_unsubscribe_url poll, poll_mailer_utm_hash.merge(unsubscribe_token: recipient.unsubscribe_token)
  end

  def poll_mailer_utm_hash
    {
      utm_medium: 'email',
      utm_campaign: 'poll_mailer',
      utm_source: action_name
    }
  end

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
      markdownify(text)
    else
      replace_iframes(text)
    end.html_safe
  end

  def render_plain_text(text, format = 'md')
    return "" unless text
    ActionController::Base.helpers.strip_tags(render_rich_text(text, format))
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
