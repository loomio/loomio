module Ability::MembershipRequest
  def initialize(user)
    super(user)

    can :create, ::MembershipRequest do |request|
      group = request.group
      can?(:show, group) and group.membership_granted_upon_approval?
    end

    can :cancel, ::MembershipRequest, requestor_id: user.id

    can [:approve,
         :ignore], ::MembershipRequest do |membership_request|
      group = membership_request.group

      user_is_admin_of?(group.id) or
        (user_is_member_of?(group.id) and group.members_can_add_members?)
    end
  end
end
