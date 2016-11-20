class Events::UserJoinedGroup < Event
  def self.publish!(membership)
    create(kind: "user_joined_group",
           user: membership.user,
           eventable: membership).tap { |e| EventBus.broadcast('user_joined_group_event', e) }
  end
end
