class Events::NewCoordinator < Event
  include Events::NotifyUser

  def self.publish!(membership, actor)
    create(kind: "new_coordinator",
           user: actor,
           eventable: membership).tap { |e| EventBus.broadcast('new_coordinator_event', e) }
  end

  private

  def notification_recipients
    User.where(id: eventable.user_id)
  end
end
