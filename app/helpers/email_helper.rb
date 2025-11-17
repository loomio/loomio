module EmailHelper
  include PrettyUrlHelper
  def login_token(recipient, redirect_path)
    recipient.login_tokens.create!(redirect: redirect_path)
  end


  # convert html to markdown if necessary
  def render_markdown(str, format = 'md')
    MarkdownService.render_markdown(str, format)
  end

  # stripped of any user generated html
  # newlines converted to brs
  def force_plain_text(str, format = 'md')
    MarkdownService.render_plain_text(str, format)
  end

  # translate plain text if required
  # refuse to take formatted content
  def plain_text(model, field)
    if show_translation(model)
      TranslationService.create(model: model, to: @recipient.locale).fields[String(field)]
    else
      model.send(field)
    end
  end

  # render markdown if necessary
  # translate if required
  # prepare formatted text for email use
  def formatted_text(model, field)
    format_field = "#{field}_format"
    content_format = 'html'

    content = if show_translation(model)
      translation = TranslationService.create(model: model, to: @recipient.locale)
      translation.fields[String(field)]
    else
      content_format = 'md' if model.send("#{field}_format") == "md"
      model.send(field)
    end

    MarkdownService.render_rich_text(content, content_format)
  end

  def show_translation(model)
    TranslationService.available? &&
    model.content_locale.present? &&
    model.content_locale != @recipient.locale &&
    @recipient.auto_translate
  end

  def recipient_stance(recipient, poll)
    poll.poll.stances.latest.find_by(participant: recipient) || Stance.new(poll: poll, participant: recipient)
  end

  def formatted_time_zone
    ActiveSupport::TimeZone[@recipient.time_zone].to_s
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

  def preferences_url
    email_preferences_url(unsubscribe_token: @recipient.unsubscribe_token)
  end

  def unsubscribe_url(eventable)
    email_actions_unsubscribe_url(eventable.named_id.merge({unsubscribe_token: @recipient.unsubscribe_token}))
  end

  def pixel_src(event)
    email_actions_mark_discussion_as_read_url(
      discussion_id: event.eventable.discussion.id,
      event_id: event.id,
      unsubscribe_token: @recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def mark_notification_as_read_pixel_src(notification_id)
    email_actions_mark_notification_as_read_url(
      id: notification_id,
      unsubscribe_token: @recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def can_unfollow?(discussion, recipient)
    DiscussionReader.for(discussion: discussion, user: recipient).volume_is_loud?
  end

  def reply_to_address(model:, user: )
    letter = {
      'Comment' => 'c',
      'Poll' => 'p',
      'Stance' => 's',
      'Outcome' => 'o'
    }[model.class.to_s]

    address = {
      pt: letter,
      pi: letter ? model.id : nil,
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

  def option_name(name, format, zone, date_time_pref)
    case format
    when 'i18n'
      t(name)
    when 'iso8601'
      format_iso8601_for_humans(name, zone, date_time_pref)
    else
      name
    end
  end

  def google_pie_chart_url(poll)
    pie_chart_url(scores: proposal_sparkline(poll), colors: proposal_colors(poll))
  end

  def proposal_sparkline(poll)
    poll.results.map {|h| h[:score] }.join(',')
  end

  def proposal_colors(poll)
    poll.results.map{|h|h[:color]}.map{|c| c.gsub('#', '')}.join(',')
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

  def optional_link(url, attrs = {}, &block)
    if url
      content_tag(:a, {href: url}.merge(attrs)) do
        block.call
      end
    else
      content_tag(:span) do
        block.call
      end
    end
  end
end
