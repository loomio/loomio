module Ability::Membership
  def initialize(user)
    super(user)

    can [:update], ::Membership do |membership|
      membership.user_id == user.id
    end

    can [:make_admin], ::Membership do |membership|
      user_is_admin_of?(membership.group_id)
    end

    can :resend, ::Membership do |membership|
      !membership.accepted_at? && user == membership.inviter
    end

    can [:remove_admin, :destroy], ::Membership do |membership|
      (membership.group.members.size > 1) &&
      (!membership.admin? or membership.group.admin_memberships_count > 1) &&
      (membership.user == user ||
       user_is_admin_of?(membership.group_id) ||
       (membership.inviter == user && !membership.accepted_at?))
    end
  end
end
