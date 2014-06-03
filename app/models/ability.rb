class Ability
  include CanCan::Ability

  def user_is_member_of?(group_id)
    @member_group_ids.include?(group_id)
  end

  def user_is_admin_of?(group_id)
    @admin_group_ids.include?(group_id)
  end

  def initialize(user)

    user ||= User.new
    @admin_group_ids = user.adminable_group_ids
    @member_group_ids = user.group_ids


    cannot :sign_up, User

    can :show, Group do |group|
      if group.is_archived?
        false
      else
        group.is_visible_to_public? or
        user_is_member_of?(group.id) or
        (group.is_visible_to_parent_members? and user_is_member_of?(group.parent_id))
      end
    end

    can :see_private_content, Group do |group|
      if group.is_archived?
        false
      else
        user_is_member_of?(group.id) or
        (group.is_visible_to_parent_members? and user_is_member_of?(group.parent_id))
      end
    end

    can [:view_payment_details,
         :choose_subscription_plan], Group do |group|
      group.is_parent? and user_is_admin_of?(group.id) and (!group.has_manual_subscription?)
    end

    can [:update,
         :email_members,
         :hide_next_steps,
         :edit_description,
         :archive], Group do |group|
      user_is_admin_of?(group.id)
    end

    can [:add_subgroup,
         :members_autocomplete], Group do |group|
      user_is_member_of?(group.id)
    end

    can [:add_members,
         :invite_people,
         :manage_membership_requests], Group do |group|

      if group.members_can_add_members?
        user_is_member_of?(group.id)
      else
        user_is_admin_of?(group.id)
      end
    end

    can :create, Group do |group|
      if !group.is_subgroup?
        true
      elsif user_is_member_of?(group.parent_id)
        true
      else
        false
      end
    end

    can :join, Group do |group|
      can?(:show, group) and group.membership_granted_upon_request?
    end

    can [:make_admin], Membership do |membership|
      @admin_group_ids.include?(membership.group_id)
    end

    can [:remove_admin,
         :destroy], Membership do |membership|
      if membership.group.members.size == 1
        false
      elsif membership.admin? and membership.group.admins.size == 1
        false
      else
        (membership.user == user) or user_is_admin_of?(membership.group_id)
      end
    end

    can :deactivate, User do |user_to_deactivate|
      not user_to_deactivate.adminable_groups.published.any? { |g| g.admins.count == 1 }
    end

    can :create, MembershipRequest do |request|
      group = request.group
      can?(:show, group) and group.membership_granted_upon_approval?
    end

    can :cancel, MembershipRequest, requestor_id: user.id

    can :cancel, Invitation do |invitation|
      (invitation.inviter == user) or user_is_admin_of?(invitation.group.id)
    end

    can [:approve,
         :ignore], MembershipRequest do |membership_request|
      group = membership_request.group

      user_is_admin_of?(group.id) or
        (user_is_member_of?(group.id) and group.members_can_add_members?)
    end

    can :show, Discussion do |discussion|
      if discussion.is_archived?
        false
      else
        discussion.public? or
        user_is_member_of?(discussion.group_id) or
        (discussion.group.is_visible_to_parent_members? and user_is_member_of?(discussion.group.parent_id))
      end
    end

    can :update, Discussion do |discussion|
      (discussion.author == user) or user_is_admin_of?(discussion.group_id)
    end

    can [:destroy,
         :move], Discussion do |discussion|
      user_is_admin_of?(discussion.group_id)
    end

    can [:unfollow,
         :add_comment,
         :new_proposal,
         :create,
         :update_description,
         :edit_title,
         :show_description_history,
         :preview_version,
         :like_comments,
         :update_version], Discussion do |discussion|
      user_is_member_of?(discussion.group_id)
    end

    can [:destroy], Comment do |comment|
      (comment.author == user) or user_is_admin_of?(comment.discussion.group_id)
    end

    can [:start_proposal], Discussion do |discussion|
      can? :create, Motion.new(discussion: discussion)
    end

    can [:create], Motion do |motion|
      motion.discussion.current_motion.nil? && user_is_member_of?(motion.discussion.group_id)
    end

    can [:vote], Motion do |motion|
      motion.voting? && user_is_member_of?(motion.discussion.group_id)
    end

    can [:close, :edit_close_date], Motion do |motion|
      motion.voting? && ((motion.author_id == user.id) || user_is_admin_of?(motion.discussion.group_id))
    end
    
    can [:show], Comment do |comment|
      can?(:show, comment.discussion)      
    end
    
    can [:show], Motion do |motion|
      can?(:show, motion.discussion)      
    end
    
    can [:show], Vote do |vote|
      can?(:show, vote.motion)      
    end
    
    can [:destroy,
         :create_outcome,
         :update_outcome], Motion do |motion|
      (motion.author_id == user.id) or user_is_admin_of?(motion.discussion.group_id)
    end
  end
end

