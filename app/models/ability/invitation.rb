module Ability::Invitation
  def initialize(user)
    super(user)

    can [:create, :resend], ::Invitation do |invitation|
      can? :invite_people, invitation.group
    end

    can :cancel, ::Invitation do |invitation|
      (invitation.inviter == user) or user_is_admin_of?(invitation.group_id)
    end
  end
end
