module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    eventable.groups.each do |group|
      MessageChannelService.publish_data(event_collection, to: group.message_channel)
    end
  end

  handle_asynchronously :notify_clients!

  def event_collection
    @event_collection ||= EventCollection.new(self).serialize!
  end
end
