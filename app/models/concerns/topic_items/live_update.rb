module TopicItems::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless itemable
    return if hidden_stance_event?

    if itemable.group_id
      MessageChannelService.publish_models([ self ], group_id: itemable.group_id)
    end
    if itemable.respond_to?(:topic)
      itemable.topic.guests.find_each do |user|
        MessageChannelService.publish_models([ self ], user_id: user.id)
      end
    end
  end

  private

  def hidden_stance_event?
    itemable.is_a?(Stance) && !itemable.shared_update_visible?
  end
end
