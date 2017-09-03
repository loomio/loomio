class Events::GroupIdentityCreated < Event
  include Events::Notify::ThirdParty

  def self.publish!(group_identity, actor)
    create(kind: "group_identity_created",
           user: actor,
           eventable: group_identity,
           announcement: group_identity.make_announcement,
           created_at: group_identity.created_at).tap { |e| EventBus.broadcast('group_identity_created', e) }
  end

  def identities
    return Identities::Base.none unless announcement
    super.where(id: eventable.identity_id)
  end
end
