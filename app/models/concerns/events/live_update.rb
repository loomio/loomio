module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless eventable
    return if hidden_stance_event?

    if eventable.group_id
      MessageChannelService.publish_models([ self ], group_id: eventable.group_id)
    end
    if eventable.respond_to?(:topic)
      eventable.topic.guests.find_each do |user|
        MessageChannelService.publish_models([ self ], user_id: user.id)
      end
    end
  end

  private

  def hidden_stance_event?
    eventable.is_a?(Stance) && !eventable.shared_update_visible?
  end
end
