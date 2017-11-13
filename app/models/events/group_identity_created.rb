class Events::GroupIdentityCreated < Event
  include Events::Notify::ThirdParty

  def self.publish!(group_identity, actor)
    super group_identity,
      user: actor,
      announcement: true,
      created_at: group_identity.created_at
  end

  def identities
    return Identities::Base.none unless announcement
    super.where(id: eventable.identity_id)
  end
end
