class MembershipService
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

  def self.add_users_to_discussion(users: nil, discussion: nil, inviter: nil, message: nil)
    memberships = discussion.group.add_members!(users, inviter)
    memberships.each do |m|
      Events::UserAddedToGroup.publish!(m, inviter)
      UserMailer.delay.added_to_discussion(user: m.user, inviter: m.inviter,
                                           discussion: discussion, message: message)
    end
  end

  def self.suspend_membership!(membership: membership)
    membership.suspend!
  end
end
