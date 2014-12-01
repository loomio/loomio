class MembershipService

  def self.update(membership: membership, params: params, actor: actor)
    actor.ability.authorize! :follow_by_default, membership
    membership.update! following_by_default: params[:following_by_default]
  end

  def self.make_admin(membership: membership, params: params, actor: actor)
    actor.ability.authorize! :make_admin, membership
    membership.update admin: true
  end

  def self.remove_admin(membership: membership, params: params, actor: actor)
    actor.ability.authorize! :remove_admin, membership
    membership.update admin: false
  end

  def self.join_group(user: nil, group: nil)
    user.ability.authorize! :join, group
    membership = group.add_member!(user)
    Events::UserJoinedGroup.publish!(membership)
  end

  def self.add_users_to_group(users: nil, group: nil, inviter: nil, message: nil)
    memberships = group.add_members!(users, inviter)
    memberships.each do |m|
      Events::UserAddedToGroup.publish!(m, inviter)
      UserMailer.delay.added_to_group(user: m.user, inviter: m.inviter,
                                      group: m.group, message: message)
    end
  end

  def self.destroy(membership: membership, actor: actor)
    actor.ability.authorize! :destroy, membership
    membership.destroy
  end

  def self.suspend_membership!(membership: membership)
    membership.suspend!
  end
end
