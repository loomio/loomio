class Ability
  include CanCan::Ability

  def user_is_member_of?(group_id)
    @member_group_ids.include?(group_id)
  end

  def user_is_admin_of?(group_id)
    @admin_group_ids.include?(group_id)
  end

  def user_is_author_of?(object)
    object.author_id == @user.id
  end

  def initialize(user)

    user ||= User.new
    @user = user
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
         :archive], Group do |group|
      user_is_admin_of?(group.id)
    end


    can [:members_autocomplete, :follow, :unfollow, :see_members], Group do |group|
      user_is_member_of?(group.id)
    end

    can [:add_members,
         :invite_people,
         :manage_membership_requests], Group do |group|
      (group.members_can_add_members? && user_is_member_of?(group.id)) || user_is_admin_of?(group.id)
    end

    # please note that I don't like this duplication either.
    # add_subgroup checks against a parent group
    can [:add_subgroup], Group do |group|
      group.is_parent? &&
      user_is_member_of?(group.id) &&
      (group.members_can_create_subgroups? || user_is_admin_of?(group.id))
    end

    # create group checks against the group to be created
    can :create, Group do |group|
      # anyone can create a top level group of their own
      # otherwise, the group must be a subgroup
      # inwhich case we need to confirm membership and permission

      group.is_parent? ||
       ((user_is_member_of?(group.parent.id) && group.parent.members_can_create_subgroups?)) ||
       user_is_admin_of?(group.parent.id)
    end

    can :join, Group do |group|
      can?(:show, group) and group.membership_granted_upon_request?
    end

    can [:make_admin], Membership do |membership|
      @admin_group_ids.include?(membership.group_id)
    end

    can [:follow_by_default], Membership do |membership|
      membership.user.id == @user.id      
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

    can [:show,
         :mark_as_read], Discussion do |discussion|
      if discussion.is_archived?
        false
      elsif discussion.group.is_archived?
        false
      else
        discussion.public? or
        user_is_member_of?(discussion.group_id) or
        (discussion.group.is_visible_to_parent_members? and user_is_member_of?(discussion.group.parent_id))
      end
    end

    can :update_version, Discussion do |discussion|
      user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
    end

    can :update, Discussion do |discussion|
      if discussion.group.members_can_edit_discussions?
        user_is_member_of?(discussion.group_id)
      else
        user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
      end
    end

    can [:destroy, :move], Discussion do |discussion|
      user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
    end

    can :create, Discussion do |discussion|
      (discussion.group.members_can_start_discussions? &&
       user_is_member_of?(discussion.group_id)) ||
      user_is_admin_of?(discussion.group_id)
    end

    can [:unfollow,
         :follow,
         :new_proposal,
         :show_description_history,
         :preview_version], Discussion do |discussion|
      user_is_member_of?(discussion.group_id)
    end

    can [:create], Comment do |comment|
      user_is_member_of?(comment.group.id) && user_is_author_of?(comment)
    end

    can [:update], Comment do |comment|
      user_is_member_of?(comment.group.id) && user_is_author_of?(comment) && comment.can_be_edited?
    end

    can :like, Comment do |comment|
      user_is_member_of?(comment.group.id)
    end

    can :add_comment, Discussion do |discussion|
      user_is_member_of?(discussion.group_id)
    end

    can [:destroy], Comment do |comment|
      user_is_author_of?(comment) or user_is_admin_of?(comment.discussion.group_id)
    end

    can [:destroy], Attachment do |attachment|
      attachment.user_id == user.id
    end

    can [:create], Motion do |motion|
      discussion = motion.discussion
      discussion.motion_can_be_raised? &&
      ((discussion.group.members_can_raise_motions? &&
        user_is_member_of?(discussion.group_id)) ||
        user_is_admin_of?(discussion.group_id) )
    end

    can [:vote], Motion do |motion|
      discussion = motion.discussion
      motion.voting? &&
      ((discussion.group.members_can_vote? && user_is_member_of?(discussion.group_id)) ||
        user_is_admin_of?(discussion.group_id) )
    end

    can [:create], Vote do |vote|
      motion = vote.motion
      can? :vote, motion
    end

    can [:close, :edit_close_date], Motion do |motion|
      motion.persisted? && motion.voting? && ((motion.author_id == user.id) || user_is_admin_of?(motion.discussion.group_id))
    end

    can [:close], Motion do |motion|
      motion.persisted? && motion.voting? &&
       ( user_is_admin_of?(motion.discussion.group_id) or user_is_author_of?(motion) )
    end

    can [:update], Motion do |motion|
      motion.voting? &&
      (motion.can_be_edited? || (not motion.restricted_changes_made?)) &&
      (user_is_admin_of?(motion.discussion.group_id) || user_is_author_of?(motion))
    end

    can [:destroy,
         :create_outcome,
         :update_outcome], Motion do |motion|
      user_is_author_of?(motion) or user_is_admin_of?(motion.discussion.group_id)
    end

    can [:show], Comment do |comment|
      can?(:show, comment.discussion)
    end

    can [:show, :history], Motion do |motion|
      can?(:show, motion.discussion)
    end

    can [:show], Vote do |vote|
      can?(:show, vote.motion)
    end

  end
end

