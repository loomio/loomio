class MessageChannelService
  def self.channel_for_event(event)
    if ['comment_liked', 'comment_replied_to', 'new_comment'].include? event.kind
      "/discussion-#{event.discussion_key}"
    else
      false
    end
  end

  def self.publish_event(event)
    if channel = channel_for_event(event)
      data = EventSerializer.new(event).as_json
      publish(channel, data)
    end
  end

  def self.publish_notification(notification)
    channel = "/user-#{notification.user_id}"
    data = NotificationSerializer.new(notification).as_json
    publish(channel, data)
  end

  def self.publish(channel, data)
    return if Rails.env.test?
    if ENV['DELAY_FAYE']
      PrivatePub.delay(priority: 10).publish_to(channel, data)
    else
      PrivatePub.publish_to(channel, data)
    end
  end
end
