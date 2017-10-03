class GroupIdentityService
  def self.create(group_identity:, actor:)
    actor.ability.authorize! :create, group_identity

    existing = GroupIdentity.find_by(group: group_identity.group, identity: group_identity.identity) do |gi|
      gi&.assign_attributes(custom_fields: group_identity.custom_fields)
    end
    group_identity = existing || group_identity

    return false unless group_identity.valid?
    group_identity.save!

    Events::GroupIdentityCreated.publish!(group_identity, actor)
    EventBus.broadcast('group_identity_create', group_identity, actor)
  end

  def self.destroy(group_identity:, actor:)
    actor.ability.authorize! :destroy, group_identity
    group_identity.destroy
    EventBus.broadcast('group_identity_destroy', group_identity, actor)
  end
end
