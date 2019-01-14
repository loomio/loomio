class Events::GroupIdentityCreated < Event

  def self.publish!(group_identity, actor)
    super group_identity,
          user: actor,
          announcement: group_identity.make_announcement
  end

  def identities
    return Identities::Base.none unless announcement
    super.where(id: eventable.identity_id)
  end
end
