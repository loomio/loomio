class Events::GroupIdentityCreated < Event
  include Events::Notify::ThirdParty

  def self.publish!(group_identity, actor)
    create(kind: "group_identity_created",
           user: actor,
           eventable: group_identity,
           announcement: true,
           created_at: group_identity.created_at).tap { |e| EventBus.broadcast('group_identity_created', e) }
  end

  def identities
    super.where(id: eventable.identity_id)
  end
end
