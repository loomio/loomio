module Events::LiveUpdate
  def trigger!
    super
    notify_clients!
  end

  # send client live updates
  def notify_clients!
    return unless eventable and eventable.group
    MessageChannelService.publish_models(self, group_ids: [eventable.group.id])
  end
end
