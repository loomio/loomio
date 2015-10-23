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

  def self.subscribe_to(user:, model:)
    raise AccessDeniedError.new unless can_subscribe?(user: user, model: model)
    PrivatePub.subscription(channel: channel_for(model), server: ENV['FAYE_URL'])
  end

  def self.can_subscribe?(user:, model:)
    case model
    when Group      then user.ability.can? :see_private_content, model
    when Discussion then user.ability.can? :show, model
    when User       then user.ability.can? :see_notifications_for, model
    else                 raise UnknownChannelError.new
    end
  end

  def self.channel_for(model)
    "/#{model.class.to_s.downcase}-#{model.key}"
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

  def self.publish(model, data)
    return if Rails.env.test? or !ENV.has_key?('FAYE_URL')
    if ENV['DELAY_FAYE']
      PrivatePub.delay(priority: 10).publish_to(channel_for(model), data)
    else
      PrivatePub.publish_to(channel_for(model), data)
    end
  end
end
