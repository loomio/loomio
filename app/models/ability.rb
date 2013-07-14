class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    cannot :sign_up, User

    # GROUPS
    can :show, Group, :viewable_by => 'everyone'
    can :show, Group, :viewable_by => 'members', :id => user.group_ids
    can :show, Group, :viewable_by => 'parent_group_members', :parent_id => user.group_ids
    can [:update, :email_members, :edit_privacy, :hide_next_steps], Group, :id => user.adminable_group_ids
    can :edit_description, Group, :id => user.group_ids
    can [:add_subgroup, :get_members], Group, :id => user.group_ids
    can [:add_members, :manage_membership_requests], Group, :members_invitable_by => 'members', :id => user.group_ids
    can [:add_members, :manage_membership_requests], Group, :members_invitable_by => 'admins', :id => user.adminable_group_ids
    can :archive, Group, :id => user.adminable_group_ids
    can :request_membership, Group

    can :create, Group do |group|
      #needs to be block becuase the subgroup does not exist in database
      group.parent.members.include? user
    end

    # MEMBERSHIPS
    can :create, Membership

    can [:make_admin, :remove_admin], Membership, :group_id => user.adminable_group_ids

    can :destroy, Membership, :user_id => user.id
    can :destroy, Membership, :group_id => user.adminable_group_ids
    cannot :destroy, Membership do |membership|
      (membership.group.users.size == 1) ||
      (membership.admin? and membership.group.admins.size == 1)
    end

    # MEMBERSHIP REQUESTS
    can :create, MembershipRequest, group: {viewable_by: 'everyone'}
    can :create, MembershipRequest, group: {viewable_by: 'parent_group_members', parent_id: user.group_ids}

    can :cancel, MembershipRequest, requestor_id: user.id

    can [:manage_membership_requests, :approve, :ignore], MembershipRequest,
      group_id: user.group_ids, group: {members_invitable_by: 'members'}

    can [:manage_membership_requests, :approve, :ignore], MembershipRequest,
      group_id: user.adminable_group_ids, group: {members_invitable_by: 'admins'}

    # DISCUSSIONS / COMMENTS
    can :show, Discussion, group: {viewable_by: 'everyone'}
    can :show, Discussion, group: {viewable_by: 'members'}, group_id: user.group_ids
    can :show, Discussion, group: {viewable_by: 'parent_group_members'}, group: {parent_id: user.group_ids}
    can :show, Discussion, group: {viewable_by: 'parent_group_members'}, group_id: user.group_ids

    can :destroy, Discussion, group_id: user.adminable_group_ids
    can :move, Discussion, group_id: user.adminable_group_ids
    can [:unfollow,
         :add_comment,
         :new_proposal,
         :create,
         :update_description,
         :edit_title,
         :show_description_history,
         :preview_version,
         :update_version,
         :show], Discussion, :group_id => user.group_ids

    can :destroy, Comment, user_id: user.id
    can :destroy, Comment, :discussion => { group_id: user.adminable_group_ids }

    can [:like, :unlike], Comment, :discussion => { :id => user.discussion_ids }

    # MOTIONS
    can :get_and_clear_new_activity, Motion do |motion|
      can? :show, motion.group
    end
    can :create, Motion, :discussion_id => user.discussion_ids
    can [:destroy, :close, :edit_outcome, :edit_close_date], Motion, :author_id => user.id
    can [:destroy, :close, :edit_outcome, :edit_close_date], Motion,
      :discussion => { :group_id => user.adminable_group_ids }
  end
end
