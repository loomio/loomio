class Events::GroupIdentityCreated < Event
  include Events::Notify::ThirdParty

  def self.publish!(group_identity, actor)
    super(group_identity, user: actor, announcement: true)
  end

  def identities
    super.where(id: eventable.identity_id)
  end
end
