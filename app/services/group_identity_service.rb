class GroupIdentityService
  def self.create(group_identity:, actor:)
    actor.ability.authorize! :create, group_identity

    return false unless group_identity.valid?
    group_identity.save!

    Events::GroupIdentityCreated.publish!(group_identity, actor)
    EventBus.broadcast('group_identity_create', group_identity, actor)
  end
end
