module EmailHelper
  include PrettyUrlHelper
  def login_token(recipient, redirect_path)
    recipient.login_tokens.create!(redirect: redirect_path)
  end

  def render_plain_text(str, fmt = 'md')
    MarkdownService.render_plain_text(str, fmt)
  end
  
  def render_rich_text(str, fmt = 'md')
    MarkdownService.render_rich_text(str, fmt)
  end
  
  def recipient_stance(recipient, poll)
    poll.poll.stances.latest.find_by(participant: recipient) || Stance.new(poll: poll, participant: recipient)
  end

  def formatted_time_zone(poll)
    time_zone = (@recipient || poll).time_zone
    ActiveSupport::TimeZone[time_zone].to_s if time_zone
  end

  def tracked_url(model, args = {})
    args.merge!({utm_medium: 'email', utm_campaign: @event&.kind })

    if model.is_a?(Poll) or model.is_a?(Outcome)
      if stance = model.poll.stances.latest.find_by(participant: @recipient)
        args.merge!(stance_token: stance.token)
      end
    end

    if model.is_a?(Discussion) || model.is_a?(Comment)
      if reader = DiscussionReader.redeemable.find_by(user: @recipient, discussion: model.discussion)
        args.merge!(discussion_reader_token: reader.token)
      end
    end

    polymorphic_url(model, args)
  end

  def unfollow_url(discussion, action_name, recipient, new_volume: :quiet)
    email_actions_unfollow_discussion_url(
      discussion_id: discussion.id,
      utm_campaign: @event.kind,
      utm_medium: 'email',
      unsubscribe_token: @recipient.unsubscribe_token,
      new_volume: new_volume
    )
  end

  def preferences_url
    tracked_url(email_preferences_url(unsubscribe_token: @recipient.unsubscribe_token))
  end

  def pixel_src(event)
    email_actions_mark_discussion_as_read_url(
      discussion_id: event.eventable.discussion.id,
      event_id: event.id,
      unsubscribe_token: @recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def can_unfollow?(discussion, recipient)
    DiscussionReader.for(discussion: discussion, user: recipient).volume_is_loud?
  end

  def stance_icon_for(poll, stance_choice)
    case stance_choice&.score.to_i
      when 0 then "disagree"
      when 1 then "abstain"
      when 2 then "agree"
    end if poll.has_score_icons
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


  def mark_summary_as_read_url_for(user, format: nil)
     email_actions_mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                                  time_start: @time_start.utc.to_i,
                                                  time_finish: @time_finish.utc.to_i,
                                                  format: format)
  end

  def option_name(name, format, zone)
    case format
    when 'i18n'
      t(name)
    when 'iso8601'
      format_iso8601_for_humans(name, zone)
    else
      name
    end
  end

  def google_pie_chart_url(poll)
    "https://chart.googleapis.com/chart?cht=p&chma=0,0,0,0|0,0&chs=256x256&chd=t:#{proposal_sparkline(poll)}&chco=#{proposal_colors(poll)}"
  end

  def proposal_sparkline(poll)
    poll.results.map {|h| h[:voter_count] }.join(',')
  end

  def proposal_colors(poll)
    poll.results.map{|h|h[:color]}.map{|c| c.gsub('#', '')}.join('|')
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
