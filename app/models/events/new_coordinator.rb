class Events::NewCoordinator < Event
  def self.publish!(membership, actor)
    create(kind: "new_coordinator",
           user: actor,
           eventable: membership).tap { |e| EventBus.broadcast('new_coordinator_event', e, membership.user) }
  end
end
