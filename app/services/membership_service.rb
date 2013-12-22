class MembershipService

  def self.add_users_to_group(users: nil, group: nil, inviter: nil)
    memberships = group.add_members!(users, inviter)
    memberships.each { |m| Events::UserAddedToGroup.publish!(m, inviter) }
  end
end