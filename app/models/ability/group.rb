module Ability::Group
  def initialize(user)
    super(user)

    can [:show], ::Group do |group|
      if group.archived_at || group.is_guest_group?
        false
      else
        group.is_visible_to_public? or
        user_is_member_of?(group.id) or
        (group.is_visible_to_parent_members? and user_is_member_of?(group.parent_id))
      end
    end

    can [:vote_in], ::Group do |group|
      if group.is_formal_group?
        user_is_admin_of(group.id) ||
        (user_is_member_of(group.id) && group.members_can_vote)
      else
        user_is_member_of(group.id)
      end
    end

    can [:see_private_content, :subscribe_to], ::Group do |group|
      if group.archived_at
        false
      else
        (group.is_guest_group? && user.ability.can?(:show, group.target_model)) or
        user_is_member_of?(group.id) or
        group.group_privacy == 'open' or
        (group.is_visible_to_parent_members? and user_is_member_of?(group.parent_id))
      end
    end

    can [:update,
         :email_members,
         :archive,
         :publish,
         :export,
         :view_pending_invitations], ::Group do |group|
      user_is_admin_of?(group.id)
    end

    can [:members_autocomplete,
         :set_volume,
         :see_members,
         :make_draft,
         :move_discussions_to,
         :view_previous_proposals], ::Group do |group|
      user.email_verified? && user_is_member_of?(group.id)
    end

    can [:add_members,
         :invite_people,
         :announce,
         :manage_membership_requests], ::Group do |group|
      user.email_verified? && Subscription.for(group).is_active? && !group.has_max_members &&
      ((group.members_can_add_members? && user_is_member_of?(group.id)) ||
      user_is_admin_of?(group.id))
    end

    # please note that I don't like this duplication either.
    # add_subgroup checks against a parent group
    can [:add_subgroup], ::Group do |group|
      user.email_verified? &&
      group.is_parent? &&
      user_is_member_of?(group.id) &&
      (group.members_can_create_subgroups? || user_is_admin_of?(group.id))
    end

    can :move, ::Group do |group|
      user.is_admin
    end

    # create group checks against the group to be created
    can :create, ::Group do |group|
      # anyone can create a top level group of their own
      # otherwise, the group must be a subgroup
      # inwhich case we need to confirm membership and permission
      (user.is_admin or AppConfig.app_features[:create_group]) &&
      user.email_verified? &&
      group.is_parent? ||
      ( user_is_admin_of?(group.parent_id) ||
        (user_is_member_of?(group.parent_id) && group.parent.members_can_create_subgroups?) )
    end

    can :join, ::Group do |group|
      user.email_verified? &&
      can?(:show, group) &&
      group.membership_granted_upon_request?
    end

    can :start_poll, ::Group do |group|
      user_is_admin_of?(group&.id) ||
      (user_is_member_of?(group&.id) && group.members_can_raise_motions)
    end

    can :merge, ::Group do |group|
      user.is_admin?
    end
  end
end
