module EmailHelper
  include PrettyUrlHelper

  def recipient_stance(recipient, poll)
    poll.poll.stances.latest.find_by(participant: recipient) || Stance.new(poll: poll, participant: recipient)
  end

  def tracked_url(model, recipient: nil, event: nil, args: {}, **extra_args)
    args = args.merge(extra_args)
    args.merge!(utm_medium: 'email', utm_campaign: event&.kind)

    if recipient
      if model.is_a?(Poll) or model.is_a?(Outcome)
        if stance = model.poll.stances.latest.find_by(participant: recipient)
          args.merge!(stance_token: stance.token)
        end
      end

      if model.is_a?(Discussion) || model.is_a?(Comment)
        if reader = TopicReader.redeemable.find_by(user: recipient, topic_id: model.topic_id)
          args.merge!(topic_reader_token: reader.token)
        end
      end
    end

    polymorphic_url(model, args)
  end

  def preferences_url(recipient:)
    email_preferences_url(unsubscribe_token: recipient.unsubscribe_token)
  end

  def unsubscribe_url(eventable, recipient:)
    email_actions_unsubscribe_url(eventable.named_id.merge({unsubscribe_token: recipient.unsubscribe_token}))
  end

  def pixel_src(event, recipient:)
    topic = event.topic
    return nil unless topic&.topicable_type == 'Discussion'
    email_actions_mark_discussion_as_read_url(
      discussion_id: topic.topicable_id,
      event_id: event.id,
      unsubscribe_token: recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def mark_notification_as_read_pixel_src(notification_id, recipient:)
    email_actions_mark_notification_as_read_url(
      id: notification_id,
      unsubscribe_token: recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def reply_to_address(model:, user:)
    letter = {
      'Comment' => 'c',
      'Poll' => 'p',
      'Stance' => 's',
      'Outcome' => 'o'
    }[model.class.to_s]

    address = {
      pt: letter,
      pi: letter ? model.id : nil,
      d: model.topic&.topicable_type == 'Discussion' ? model.topic.topicable_id : nil,
      u: user.id,
      k: user.email_api_key
    }.compact.map { |k, v| [k, v].join('=') }.join('&')
    [address, ENV['REPLY_HOSTNAME']].join('@')
  end

  def mark_summary_as_read_url_for(user, time_start:, time_finish:, format: nil)
    email_actions_mark_summary_email_as_read_url(unsubscribe_token: user.unsubscribe_token,
                                                 time_start: time_start.utc.to_i,
                                                 time_finish: time_finish.utc.to_i,
                                                 format: format)
  end

  def google_pie_chart_url(poll)
    pie_chart_url(scores: proposal_sparkline(poll), colors: proposal_colors(poll))
  end

  def proposal_sparkline(poll)
    poll.results.map { |h| h[:score] }.join(',')
  end

  def proposal_colors(poll)
    poll.results.map { |h| h[:color] }.map { |c| c.gsub('#', '') }.join(',')
  end
end
