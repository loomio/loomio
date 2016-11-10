class Events::UserAddedToGroup < Event
  def self.publish!(membership, inviter)
    create(kind: "user_added_to_group",
           user: inviter,
           eventable: membership).tap { |e| EventBus.broadcast('user_added_to_group_event', e, membership.user) }
  end

  def notification_actor
    eventable.inviter
  end
end
