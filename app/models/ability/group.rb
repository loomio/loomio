module Ability::Group
  def initialize(user)
    super(user)

    can [:show], ::Group do |group|
      !group.archived_at &&
      (
        group.is_visible_to_public? or
        group.members.exists?(user.id) or
        (group.is_visible_to_parent_members? and user_is_member_of?(group.parent_id)) or
        (user.group_token && user.group_token == group.token) or
        (user.membership_token && group.memberships.pending.find_by(token: user.membership_token))
      )
    end

    can [:vote_in], ::Group do |group|
      group.admins.exists?(user.id) || (group.members_can_vote && group.members.exists?(user.id))
    end

    can [:see_private_content, :subscribe_to], ::Group do |group|
      !group.archived_at && (
        group.group_privacy == 'open' or
        group.members.exists?(user.id) or
        (group.is_visible_to_parent_members? and group.parent_or_self.members.exists?(user.id)))
    end

    can [:update,
         :email_members,
         :archive,
         :destroy,
         :publish,
         :export,
         :view_pending_invitations,
         :set_saml_provider], ::Group do |group|
      group.admins.exists?(user.id)
    end

    can [:members_autocomplete,
         :set_volume], ::Group do |group|
      user.email_verified? && group.members.exists?(user.id)
    end

    can [:move_discussions_to], ::Group do |group|
      user.email_verified? &&
      (group.admins.exists?(user.id) ||
      (group.members_can_start_discussions? && group.members.exists?(user.id)))
    end

    can [:add_members,
         :invite_people,
         :announce,
         :manage_membership_requests], ::Group do |group|
      user.email_verified? && Subscription.for(group).is_active? && !group.has_max_members &&
      ((group.members_can_add_members? && group.members.exists?(user.id)) || group.admins.exists?(user.id))
    end

    # please note that I don't like this duplication either.
    # add_subgroup checks against a parent group
    can [:add_subgroup], ::Group do |group|
      user.email_verified? &&
      (group.is_parent? &&
      group.members.exists?(user.id) &&
      (group.members_can_create_subgroups? || group.admins.exists?(user.id)))
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
      (user.email_verified? && can?(:show, group) && group.membership_granted_upon_request?) ||
      (user_is_admin_of?(group.parent_id) && can?(:show, group) && group.membership_granted_upon_approval?)
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
