module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    MessageChannelService.publish(event_collection, to: eventable.group)
    MessageChannelService.publish(event_collection, to: eventable.poll) if eventable.respond_to?(:poll)
  end
  handle_asynchronously :notify_clients!

  def event_collection
    @event_collection ||= EventCollection.new(self).serialize!
  end
end
