module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless eventable and eventable.group
    MessageChannelService.publish_data(event_collection, to: eventable.group.message_channel)
  end

  def event_collection
    @event_collection ||= EventCollection.new(self).serialize!
  end
end
