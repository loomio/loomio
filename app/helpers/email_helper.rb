module EmailHelper
  include PrettyUrlHelper

  def email_theme_css
    <<~CSS
      :root { color-scheme: light dark; supported-color-schemes: light dark; }
      .email-button-primary {
        background-color: #{AppConfig.theme[:primary_color]};
        color: #{AppConfig.theme[:text_on_primary_color]};
      }
      .email-button-accent {
        background-color: #{AppConfig.theme[:accent_color]};
        color: #{AppConfig.theme[:text_on_accent_color]};
      }
      .email-poll-option-standard {
        border: 1px solid #{AppConfig.theme[:primary_color]};
      }
      .email-poll-option-indicator { color: #{AppConfig.theme[:primary_color]}; }
      .email-result-bar { background-color: #{AppConfig.theme[:primary_color]}; }
      @media (prefers-color-scheme: dark) {
        .email-poll-option-standard {
          border-color: #{AppConfig.theme[:dark_primary_color]} !important;
        }
        .email-poll-option-indicator {
          color: #{AppConfig.theme[:dark_primary_color]} !important;
        }
        .email-result-bar {
          background-color: #{AppConfig.theme[:dark_primary_color]} !important;
        }
        .email-button-primary {
          background-color: #{AppConfig.theme[:dark_primary_color]} !important;
          color: #{AppConfig.theme[:dark_text_on_primary_color]} !important;
        }
        .email-button-accent {
          background-color: #{AppConfig.theme[:dark_accent_color]} !important;
          color: #{AppConfig.theme[:dark_text_on_accent_color]} !important;
        }
      }
    CSS
  end

  def recipient_stance(recipient, poll)
    return Stance.new(poll: poll.poll) unless recipient.is_a?(User)

    poll.poll.stances.latest.find_by(participant: recipient) || Stance.new(poll: poll, participant: recipient)
  end

  def tracked_url(model, recipient: nil, topic_item: nil, args: {}, **extra_args)
    args = args.merge(extra_args)
    args.merge!(utm_medium: 'email', utm_campaign: topic_item&.kind)

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

  def unsubscribe_url(itemable, recipient:)
    target = if itemable.respond_to?(:topic)
      itemable.topic
    elsif itemable.respond_to?(:poll)
      itemable.poll.topic
    elsif itemable.respond_to?(:group)
      itemable.group
    end

    email_actions_unsubscribe_url((target || itemable).named_id.merge(unsubscribe_token: recipient.unsubscribe_token))
  end

  def pixel_src(topic_item, recipient:)
    topic = topic_item.topic
    return nil unless topic&.topicable_type == 'Discussion'
    email_actions_mark_discussion_as_read_url(
      discussion_id: topic.topicable_id,
      topic_item_id: topic_item.id,
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

  def mark_digest_as_read_url_for(user, time_start:, time_finish:, format: nil)
    email_actions_mark_digest_as_read_url(unsubscribe_token: user.unsubscribe_token,
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
