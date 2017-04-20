class Ability
  include CanCan::Ability

  def user_is_member_of?(group_id)
    @user.group_ids.include?(group_id)
  end

  def user_is_admin_of?(group_id)
    @user.adminable_group_ids.include?(group_id)
  end

  def user_is_author_of?(object)
    @user.is_logged_in? && @user.id == object.author_id
  end

  def initialize(user)

    user ||= User.new
    @user = user

    cannot :sign_up, User

    can [:approve, :decline], NetworkMembershipRequest do |request|
      !request.approved? and request.network.coordinators.include? user
    end

    can :create, NetworkMembershipRequest do |request|
      request.group.admins.include?(request.requestor) and
      request.group.is_parent? and
      !request.network.groups.include?(request.group)
    end

    can :manage_membership_requests, Network do |network|
      network.coordinators.include? user
    end

    can :show, Group do |group|
      if group.archived_at
        false
      else
        group.is_visible_to_public? or
        user_is_member_of?(group.id) or
        (group.is_visible_to_parent_members? and user_is_member_of?(group.parent_id))
      end
    end

    can [:see_private_content, :subscribe_to], Group do |group|
      if group.archived_at
        false
      else
        user_is_member_of?(group.id) or
        (group.is_visible_to_parent_members? and user_is_member_of?(group.parent_id))
      end
    end

    can [:choose_subscription_plan], Group do |group|
      group.is_parent? and user_is_admin_of?(group.id)
    end

    can [:update,
         :email_members,
         :hide_next_steps,
         :archive,
         :view_pending_invitations], Group do |group|
      user_is_admin_of?(group.id)
    end

    can :export, Group do |group|
      user.is_admin? or
      (user_is_admin_of?(group.id) && group.features['dataExport'])
    end

    can [:members_autocomplete,
         :set_volume,
         :see_members,
         :make_draft,
         :move_discussions_to,
         :view_previous_proposals], Group do |group|
      user_is_member_of?(group.id)
    end

    can [:add_members,
         :invite_people,
         :manage_membership_requests,
         :view_shareable_invitation], Group do |group|
      (group.members_can_add_members? && user_is_member_of?(group.id)) ||
      user_is_admin_of?(group.id)
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
      user.is_logged_in? &&
      ( user_is_admin_of?(group.parent_id) ||
        (user_is_member_of?(group.parent_id) && group.parent.members_can_create_subgroups?) )
    end

    can :join, Group do |group|
      can?(:show, group) &&
      (group.membership_granted_upon_request? ||
       group.invitations.find_by(recipient_email: @user.email))
    end

    can [:make_admin], Membership do |membership|
      user_is_admin_of?(membership.group_id)
    end

    can [:update], DiscussionReader do |reader|
      reader.user.id == @user.id
    end

    can [:update], Membership do |membership|
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

    can :show, User do |user|
      user.deactivated_at.nil?
    end

    can :deactivate, User do |user_to_deactivate|
      not user_to_deactivate.adminable_groups.published.any? { |g| g.admins.count == 1 }
    end

    can [:update, :see_notifications_for, :make_draft, :subscribe_to], User do |user|
      @user == user
    end

    can [:subscribe_to], GlobalMessageChannel do |channel|
      true
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
         :print,
         :dismiss,
         :subscribe_to], Discussion do |discussion|
      if discussion.archived_at.present?
        false
      elsif discussion.group.archived_at.present?
        false
      else
        discussion.public? or
        user_is_member_of?(discussion.group_id) or
        (discussion.group.parent_members_can_see_discussions? and user_is_member_of?(discussion.group.parent_id))
      end
    end

    can :mark_as_read, Discussion do |discussion|
      @user.is_logged_in? && can?(:show, discussion)
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
      (discussion.group.present? &&
       discussion.group.members_can_start_discussions? &&
       user_is_member_of?(discussion.group_id)) ||
      user_is_admin_of?(discussion.group_id)
    end

    can [:set_volume,
         :new_proposal,
         :show_description_history,
         :preview_version], Discussion do |discussion|
      user_is_member_of?(discussion.group_id)
    end

    can [:create], Comment do |comment|
      comment.discussion && user_is_member_of?(comment.group.id)
    end

    can [:update], Comment do |comment|
      user_is_member_of?(comment.group.id) && user_is_author_of?(comment) && comment.can_be_edited?
    end

    can [:like, :unlike], Comment do |comment|
      user_is_member_of?(comment.group.id)
    end

    can [:add_comment, :make_draft], Discussion do |discussion|
      user_is_member_of?(discussion.group_id)
    end

    can [:destroy], Comment do |comment|
      user_is_author_of?(comment) or user_is_admin_of?(comment.discussion.group_id)
    end

    can [:create], Attachment do
      user.is_logged_in?
    end

    can [:destroy], Attachment do |attachment|
      attachment.user_id == user.id
    end

    can [:create], Motion do |motion|
      discussion = motion.discussion
      discussion.current_motion.blank? &&
      ((discussion.group.members_can_raise_motions? &&
        user_is_member_of?(discussion.group_id)) ||
        user_is_admin_of?(discussion.group_id) )
    end

    can [:vote, :make_draft], Motion do |motion|
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

    can :update, Draft do |draft|
      draft.user_id == @user.id &&
      can?(:make_draft, draft.draftable)
    end

    can [:show, :update, :destroy], OauthApplication do |application|
      application.owner_id == @user.id
    end

    can :revoke_access, OauthApplication do |application|
      OauthApplication.authorized_for(user).include? application
    end

    can :create, OauthApplication do |application|
      @user.is_logged_in?
    end

    can :show, Communities::Base do |community|
      community.polls.any? { |poll| @user.can? :share, poll }
    end

    can [:make_draft, :show], Poll do |poll|
      user_is_author_of?(poll) ||
      can?(:show, poll.discussion) ||
      poll.communities.any? { |community| community.includes?(@user) }
    end

    can :create, Poll do |poll|
      @user.is_logged_in? &&
      (!poll.group || poll.group.community.includes?(@user))
    end

    can [:update, :share], Poll do |poll|
      user_is_author_of?(poll) ||
      Array(poll.group&.admins).include?(@user)
    end

    can :close, Poll do |poll|
      poll.active? && (user_is_author_of?(poll) || user_is_admin_of?(poll.group_id))
    end

    can [:destroy], Visitor do |visitor|
      @user.visitors.include?(visitor)
    end

    can [:create, :remind], Visitor do |visitor|
      @user.communities.include?(visitor.community)
    end

    can :update, Visitor do |visitor|
      @user.can?(:create, visitor) || @user.participation_token == visitor.participation_token
    end

    can :create, Stance do |stance|
      poll = stance.poll
      if !poll.active?
        false
      elsif poll.discussion
        (poll.group.members_can_vote? && user_is_member_of?(poll.group_id)) ||
        user_is_admin_of?(poll.group_id) ||
        poll.communities.any? { |community| community.includes?(@user) }
      else
        user_is_author_of?(poll) || poll.communities.any? { |community| community.includes?(@user) }
      end
    end

    can [:create, :update], Outcome do |outcome|
      !outcome.poll.active? &&
      user.ability.can?(:update, outcome.poll)
    end

    add_additional_abilities
  end

  def add_additional_abilities
    # For plugins to add their own abilities
  end
end
