module Ability::Membership
  def initialize(user)
    super(user)

    can [:update], ::Membership do |membership|
      membership.user_id == user.id || membership.group.admins.include?(user)
    end

    can [:make_admin], ::Membership do |membership|
      membership.group.admins.include?(user) ||
      (user_is_member_of?(membership.group_id) && membership.user == user && membership.group.admin_memberships.count == 0) ||
      (user_is_admin_of?(membership.group.parent_id) && user == membership.user)
    end

    can :resend, ::Membership do |membership|
      !membership.accepted_at? && user == membership.inviter
    end

    can [:remove_admin, :destroy], ::Membership do |membership|
      (membership.user == user ||
       user_is_admin_of?(membership.group_id) ||
       (membership.inviter == user && !membership.accepted_at?))
    end
  end
end
