class MembershipService

  def self.update(membership:, params:, actor:)
    actor.ability.authorize! :update, membership
    membership.set_volume! params[:volume]
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

  def self.join_group(actor: nil, group: nil)
     actor.ability.authorize! :join, group
     membership = group.add_member!(actor)
     Events::UserJoinedGroup.publish!(membership)
   end

  def self.add_users_to_group(users: , group: , inviter: , message: nil)
    inviter.ability.authorize!(:add_members, group)
    memberships = group.add_members!(users, inviter)
    memberships.each do |m|
      Events::UserAddedToGroup.publish!(m, inviter)
      UserMailer.delay.added_to_group(user: m.user, inviter: inviter,
                                      group: m.group, message: message)
    end
  end

  def self.destroy(membership:, actor:)
    actor.ability.authorize! :destroy, membership
    membership.destroy
  end

  def self.suspend_membership!(membership:)
    membership.suspend!
  end
end
