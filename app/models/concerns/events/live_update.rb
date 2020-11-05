module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless eventable and eventable.group_id
    MessageChannelService.publish_models(self, group_id: eventable.group.id)
  end
end
