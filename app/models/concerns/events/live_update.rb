module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless eventable.topic
    if eventable.topic.group_id
      MessageChannelService.publish_models([self], group_id: eventable.topic.group.id)
    end
    if eventable.respond_to?(:topic) && eventable.topic
      eventable.topic.guests.find_each do |user|
        MessageChannelService.publish_models([self], user_id: user.id)
      end
    end
  end
end
