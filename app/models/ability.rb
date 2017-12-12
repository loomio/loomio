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

    can :show, Group do |group|
      if user.is_admin?
        true
      elsif group.archived_at || group.is_guest_group?
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

    can [:update,
         :email_members,
         :hide_next_steps,
         :archive,
         :publish,
         :view_pending_invitations], Group do |group|
      user.is_admin? || user_is_admin_of?(group.id)
    end

    can :view_pending_invitations, Poll do |poll|
      can? :view_pending_invitations, poll.guest_group
    end

    can :export, Group do |group|
      user.is_admin? or user_is_admin_of?(group.id)
    end

    can [:members_autocomplete,
         :set_volume,
         :see_members,
         :make_draft,
         :move_discussions_to,
         :view_previous_proposals], Group do |group|
      user.email_verified? && user_is_member_of?(group.id)
    end


    can [:add_members,
         :invite_people,
         :manage_membership_requests,
         :view_shareable_invitation], Group do |group|
      user.email_verified? &&
      ((group.members_can_add_members? && user_is_member_of?(group.id)) ||
      user_is_admin_of?(group.id))
    end

    can :view_shareable_invitation, Poll do |poll|
      can? :view_shareable_invitation, poll.guest_group
    end

    # please note that I don't like this duplication either.
    # add_subgroup checks against a parent group
    can [:add_subgroup], Group do |group|
      user.email_verified? &&
      group.is_parent? &&
      user_is_member_of?(group.id) &&
      (group.members_can_create_subgroups? || user_is_admin_of?(group.id))
    end

    # create group checks against the group to be created
    can :create, Group do |group|
      # anyone can create a top level group of their own
      # otherwise, the group must be a subgroup
      # inwhich case we need to confirm membership and permission
      (user.is_admin or AppConfig.app_features[:create_group]) &&
      user.email_verified? &&
      group.is_parent? ||
      ( user_is_admin_of?(group.parent_id) ||
        (user_is_member_of?(group.parent_id) && group.parent.members_can_create_subgroups?) )
    end

    can :join, Group do |group|
      user.email_verified? &&
      can?(:show, group) &&
      (group.membership_granted_upon_request? ||
       group.invitations.useable.find_by(recipient_email: @user.email))
    end

    can [:create], GroupIdentity do |group_identity|
      user_is_admin_of?(group_identity.group_id) &&
      user.identities.include?(group_identity.identity)
    end

    can [:destroy], GroupIdentity do |group_identity|
      user_is_admin_of?(group_identity.group_id)
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

    can [:create, :resend], Invitation do |invitation|
      can? :invite_people, invitation.group
    end

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

    can [:mark_as_read, :mark_as_seen], Discussion do |discussion|
      @user.is_logged_in? && can?(:show, discussion)
    end

    can :update_version, Discussion do |discussion|
      user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
    end

    can :update, Discussion do |discussion|
      user.email_verified? &&
      if discussion.group.members_can_edit_discussions?
        user_is_member_of?(discussion.group_id)
      else
        user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
      end
    end

    can :pin, Discussion do |discussion|
      user_is_admin_of?(discussion.group_id)
    end

    can [:destroy, :move], Discussion do |discussion|
      user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
    end

    can :create, Discussion do |discussion|
      (user.email_verified? &&
       discussion.group.present? &&
       discussion.group.members_can_start_discussions? &&
       user_is_member_of?(discussion.group_id)) ||
      user_is_admin_of?(discussion.group_id)
    end

    can :remove_from_thread, Event do |event|
      (user_is_author_of?(event.discussion) or
       user_is_admin_of?(event.discussion.group_id)) &&
      ['discussion_edited'].include?(event.kind)
    end

    can [:set_volume,
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

    can :update, Reaction do |reaction|
      user_is_member_of?(reaction.reactable.group.id)
    end

    can :destroy, Reaction do |reaction|
      user_is_author_of?(reaction)
    end

    can [:add_comment, :make_draft], Discussion do |discussion|
      user_is_member_of?(discussion.group_id)
    end

    can [:destroy], Comment do |comment|
      user_is_author_of?(comment) or user_is_admin_of?(comment.discussion.group_id)
    end

    can [:show], Comment do |comment|
      can?(:show, comment.discussion)
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
      @user.email_verified?
    end

    can :make_draft, Poll do |poll|
      @user.is_logged_in? && can?(:show, poll)
    end

    can :add_options, Poll do |poll|
      user_is_author_of?(poll) ||
      (@user.can?(:vote_in, poll) && poll.voter_can_add_options)
    end

    can :vote_in, Poll do |poll|
      # cant have a token of a verified user, and be logged in as another user
      poll.active? && (
        poll.members.include?(@user) ||
        poll.anyone_can_participate ||
        poll.invitations.useable.find_by(token: @user.token)
      )
    end

    can [:show, :toggle_subscription, :subscribe_to], Poll do |poll|
      poll.anyone_can_participate ||
      user_is_author_of?(poll) ||
      can?(:show, poll.discussion) ||
      poll.members.include?(@user) ||
      poll.invitations.useable.pluck(:token).include?(@user.token)
    end

    can :create, Announcement do |announcement|
      user_is_author_of?(announcement.announceable) ||
      user_is_admin_of?(announcement.announceable.group_id)
    end

    can :create, Poll do |poll|
      @user.email_verified? &&
      (!poll.group.presence || poll.group.members.include?(@user))
    end

    can [:update, :share, :remind, :destroy], Poll do |poll|
      user_is_author_of?(poll) || user_is_admin_of?(poll.group_id)
    end

    can :close, Poll do |poll|
      poll.active? && (user_is_author_of?(poll) || user_is_admin_of?(poll.group_id))
    end

    can [:show, :destroy], Identities::Base do |identity|
      @user.identities.include? identity
    end

    can :show, Stance do |stance|
      @user.can?(:show, stance.poll)
    end

    can [:make_draft, :create], Stance do |stance|
      @user.can? :vote_in, stance.poll
    end

    can [:verify, :destroy], Stance do |stance|
      @user.email_verified? &&
      stance.participant.email_verified == false &&
      stance.participant.email == @user.email
    end

    can :show, Outcome do |outcome|
      can? :show, outcome.poll
    end

    can [:create, :update], Outcome do |outcome|
      !outcome.poll.active? &&
      user.ability.can?(:update, outcome.poll)
    end

    can :create, ContactRequest do |request|
      (@user.groups & request.recipient.groups).any?
    end

    can [:create, :update], Document do |document|
      if document.model.presence
        @user.can? :update, document.model
      else
        @user.email_verified?
      end
    end

    can :destroy, Document do |document|
      user_is_admin_of? document.model.group.id
    end

    add_additional_abilities
  end

  def add_additional_abilities
    # For plugins to add their own abilities
  end
end
