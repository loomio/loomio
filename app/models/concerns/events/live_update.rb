module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless eventable and eventable.group
    MessageChannelService.publish_records(event_collection, group_ids: [eventable.group.id])
  end

  def event_collection
    @event_collection ||= EventCollection.new(self).serialize!
  end
end
