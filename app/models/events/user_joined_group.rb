class Events::UserJoinedGroup < Event
  def self.publish!(membership)
    create(kind: "user_joined_group",
           user: membership.user,
           eventable: membership).tap { |e| Loomio::EventBus.broadcast('user_joined_group_event', e) }
  end

  def membership
    eventable
  end
end
