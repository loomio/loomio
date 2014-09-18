class Events::UserJoinedGroup < Event
  def self.publish!(membership)
    create!(kind: "user_joined_group",
            user: membership.user,
            eventable: membership)
  end

  def membership
    eventable
  end
end
