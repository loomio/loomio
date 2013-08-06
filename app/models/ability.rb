class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    cannot :sign_up, User

    can :show, Group do |group|
      if group.archived?
        false
      else
        case group.viewable_by.to_s
        when 'everyone'
          true
        when 'members'
          group.members.include?(user)
        when 'parent_group_members'
          group.members.include?(user) or group.parent.members.include?(user)
        end
      end
    end

    # TODO: Refactor to use subscription resource
    can [:view_payment_details,
         :choose_subscription_plan], Group do |group|
      group.is_top_level? and group.admins.include?(user)
    end

    can [:update,
         :email_members,
         :edit_privacy,
         :hide_next_steps,
         :archive], Group do |group|
      group.admins.include?(user)
    end

    can [:add_subgroup,
        :edit_description,
        :get_members], Group do |group|
      group.members.include?(user)
    end

    can [:add_members,
         :manage_membership_requests], Group do |group|
      case group.members_invitable_by
      when 'members'
        group.members.include?(user)
      when 'admins'
        group.admins.include?(user)
      end
    end

    can :create, Group do |group|
      if group.parent.present?
        group.parent.members.include? user
      else
        false
      end
    end

    can [:make_admin], Membership do |membership|
      membership.group.admins.include?(user)
    end

    can [:remove_admin,
         :destroy], Membership do |membership|
      if membership.group.members.size == 1
        false
      elsif membership.admin? and membership.group.admins.size == 1
        false
      else
        (membership.user == user) or membership.group.admins.include?(user)
      end
    end

    can :create, MembershipRequest do |membership_request|
      group = membership_request.group
      if group.is_sub_group?
        group.parent.members.include?(user) and can?(:show, group)
      else
        can?(:show, membership_request.group)
      end
    end

    can :cancel, MembershipRequest, requestor_id: user.id

    can [:manage_membership_requests,
         :approve,
         :ignore], MembershipRequest do |membership_request|
      group = membership_request.group

      group.admins.include?(user) or
        (group.members_can_invite_members? and
         group.members.include?(user))
    end

    can :show, Discussion do |discussion|
      can? :show, discussion.group
    end

    can [:destroy,
         :move], Discussion do |discussion|
      discussion.group.admins.include?(user)
    end

    can [:unfollow,
         :add_comment,
         :new_proposal,
         :create,
         :update_description,
         :edit_title,
         :show_description_history,
         :preview_version,
         :update_version], Discussion do |discussion|
      discussion.group.members.include?(user)
    end

    can [:destroy], Comment do |comment|
      (comment.author == user) or comment.group.admins.include?(user)
    end

    can [:like,
         :unlike], Comment do |comment|
      comment.group.members.include? user
    end

    can :get_and_clear_new_activity, Motion do |motion|
      can? :show, motion.group
    end

    can :create, Motion do |motion|
      motion.group.members.include?(user)
    end

    can [:destroy,
         :close,
         :edit_outcome,
         :edit_close_date], Motion do |motion|
      (motion.author == user) or
      motion.group.admins.include?(user)
    end
  end
end
