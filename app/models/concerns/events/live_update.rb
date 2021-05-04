module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless eventable
    if eventable.group_id
      MessageChannelService.publish_models([self], group_id: eventable.group.id)
    end
    if eventable.respond_to?(:guests)
      eventable.guests.find_each do |user|
        MessageChannelService.publish_models([self], user_id: user.id)
      end
    end
  end
end
