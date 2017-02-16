module Events::LiveUpdate
  def trigger!(args = {})
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    MessageChannelService.publish(EventCollection.new(self).serialize!, to: eventable.group)
  end
  handle_asynchronously :notify_clients!
end
