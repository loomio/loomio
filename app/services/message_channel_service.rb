class MessageChannelService
  class AccessDeniedError < StandardError
  end

  class UnknownChannelError < StandardError
  end

  GROUP_EVENTS = %w(new_discussion
                    new_motion
                    new_comment
                    new_vote
                    comment_replied_to
                    discussion_title_edited
                    motion_close_date_edited
                    motion_closed
                    motion_closed_by_user
                    motion_name_edited)

  DISCUSSION_EVENTS = %w(comment_liked
                         discussion_description_edited
                         motion_description_edited)

  def self.subscribe_to(user:, channel: )
    raise AccessDeniedError.new unless can_subscribe?(user: user, channel: channel)
    PrivatePub.subscription(channel: channel, server: ENV['FAYE_URL'])
  end

  def self.can_subscribe?(user:, channel:)
    key = channel_key(channel)
    case channel_type(channel)
    when 'group'         then user.ability.can? :see_private_content, Group.find(key)
    when 'discussion'    then user.ability.can? :show, Discussion.find(key)
    when 'notifications' then key.to_i == user.id
    else                      raise UnknownChannelError.new
    end
  end

  def self.channel_type(channel)
    /\/(\w+)-(\w+)/.match(channel)[1]
  end

  def self.channel_key(channel)
    /\/(\w+)-(\w+)/.match(channel)[2]
  end

  def self.channel_for_event(event)
    if GROUP_EVENTS.include? event.kind
      "/group-#{event.group_key}"
    elsif DISCUSSION_EVENTS.include? event.kind
      "/discussion-#{event.discussion_key}"
    end
  end

  def self.publish_event(event)
    return unless channel = channel_for_event(event)
    publish channel, EventSerializer.new(event).as_json
  end

  def self.publish_notification(notification)
    publish "/notifications-#{notification.user_id}", NotificationSerializer.new(notification).as_json
  end

  def self.publish(channel, data)
    return if Rails.env.test? or !ENV.has_key?('FAYE_URL')
    if ENV['DELAY_FAYE']
      PrivatePub.delay(priority: 10).publish_to(channel, data)
    else
      PrivatePub.publish_to(channel, data)
    end
  end
end
