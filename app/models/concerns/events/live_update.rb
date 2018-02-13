module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    eventable.groups.each do |group|
      ActionCable.server.broadcast group.message_channel, event_collection
    end
  end
  
  handle_asynchronously :notify_clients!

  def event_collection
    @event_collection ||= EventCollection.new(self).serialize!
  end
end
