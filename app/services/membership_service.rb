class MembershipService

  def self.set_volume(membership:, params:, actor:)
    actor.ability.authorize! :update, membership
    if params[:apply_to_all]
      actor.memberships.update_all(volume: Membership.volumes[params[:volume]])
      actor.discussion_readers.update_all(volume: nil)
    else
      membership.set_volume! params[:volume]
      membership.discussion_readers.update_all(volume: nil)
    end
  end

  def self.make_admin(membership:, actor:)
    actor.ability.authorize! :make_admin, membership
    membership.update admin: true
    Events::NewCoordinator.publish!(membership, actor)
  end

  def self.remove_admin(membership:, actor:)
    actor.ability.authorize! :remove_admin, membership
    membership.update admin: false
  end

  def self.join_group(group:, actor:)
     actor.ability.authorize! :join, group
     membership = group.add_member!(actor)
     EventBus.broadcast('membership_join_group', group, actor)
     Events::UserJoinedGroup.publish!(membership)
   end

  def self.add_users_to_group(users: , group: , inviter: , message: nil)
    inviter.ability.authorize!(:add_members, group)
    group.add_members!(users, inviter).tap do |memberships|
      Events::UserAddedToGroup.bulk_publish!(memberships, inviter, message)
    end
  end

  def self.destroy(membership:, actor:)
    actor.ability.authorize! :destroy, membership
    membership.destroy
  end

  def self.suspend_membership!(membership:)
    membership.suspend!
  end

  def self.save_experience(membership:, actor:, params:)
    actor.ability.authorize! :update, membership
    membership.experienced!(params[:experience])
    EventBus.broadcast('membership_save_experience', membership, actor, params)
  end
end
