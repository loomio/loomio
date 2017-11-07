class Events::UserJoinedGroup < Event
  def self.publish!(membership)
    super(membership, user: membership.user)
  end
end
