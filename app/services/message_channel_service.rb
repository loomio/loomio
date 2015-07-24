class MessageChannelService
  class AccessDeniedError < StandardError
  end

  class UnknownChannelError < StandardError
  end

  def self.subscribe_to(user:, channel: )
    if can_subscribe?(user: user, channel: channel)
      PrivatePub.subscription(channel: channel, server: ENV['FAYE_URL'])
    else
      raise AccessDeniedError.new
    end
  end

  def self.can_subscribe?(user:, channel: )
    case channel_type(channel)
    when 'discussion'
      discussion = Discussion.find_by_key(channel_key(channel))
      user.ability.can?(:show, discussion)
    when 'notifications'
      channel_key(channel).to_i == user.id
    when 'group'
      Group.find_by_key(channel_key(channel)).has_member?(user)
    else
      raise UnknownChannelError.new
    end
  end

  def self.channel_type(channel)
    /\/(\w+)-(\w+)/.match(channel)[1]
  end

  def self.channel_key(channel)
    /\/(\w+)-(\w+)/.match(channel)[2]
  end

  def self.channel_for_event(event)
    group_events = %w(new_discussion
                      new_motion
                      new_comment
                      new_vote
                      comment_replied_to
                      discussion_title_edited
                      motion_close_date_edited
                      motion_closed
                      motion_closed_by_user
                      motion_name_edited)

    discussion_events = %w(comment_liked
                           discussion_description_edited
                           motion_description_edited)

    if group_events.include? event.kind
      "/group-#{event.group_key}"
    elsif discussion_events.include? event.kind
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
    channel = "/notifications-#{notification.user_id}"
    data = NotificationSerializer.new(notification).as_json

    publish(channel, data)
  end

  def self.publish(channel, data)
    return if Rails.env.test? or !ENV.has_key?('FAYE_URL')
    if ENV['DELAY_FAYE']
      PrivatePub.delay(priority: 10).publish_to(channel, data)
    else
      PrivatePub.publish_to(channel, data)
    end
  end

  def self.channel_regexes
    [/discussion-(\w+)/, /notifications-(\w+)/]
  end

  def self.valid_channel?(channel)
    channel_regexes.any? do |regex|
      regex.match(channel)
    end
  end
end
