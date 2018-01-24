module Ability::Membership
  def initialize(user)
    super(user)

    can [:update], ::Membership do |membership|
      membership.user_id == user.id
    end

    can [:make_admin], ::Membership do |membership|
      user_is_admin_of?(membership.group_id)
    end

    can [:remove_admin,
         :destroy], ::Membership do |membership|
      if membership.group.members.size == 1
        false
      elsif membership.admin? and membership.group.admins.size == 1
        false
      else
        (membership.user == user) or user_is_admin_of?(membership.group_id)
      end
    end

  end
end
