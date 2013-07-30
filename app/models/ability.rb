class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    cannot :sign_up, User

    # GROUPS
    can :show, Group do |group|
      return false if group.archived?

      case group.viewable_by.to_s
      when 'everyone'
        true
      when 'members'
        group.members.include?(user)
      when 'parent_group_members'
        group.members.include?(user) or group.parent.members.include?(user)
      end
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

    can :request_membership, Group

    can :create, Group do |group|
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

    #
    # MEMBERSHIP REQUESTS
    #
    can :create, MembershipRequest, group: {viewable_by: 'everyone', parent_id: nil}
    can :create, MembershipRequest, group: {viewable_by: 'everyone', parent_id: user.group_ids}
    can :create, MembershipRequest, group: {viewable_by: 'parent_group_members', parent_id: user.group_ids}

    can :cancel, MembershipRequest, requestor_id: user.id

    can [:manage_membership_requests, :approve, :ignore], MembershipRequest,
      group_id: user.group_ids, group: {members_invitable_by: 'members'}

    can [:manage_membership_requests, :approve, :ignore], MembershipRequest,
      group_id: user.adminable_group_ids, group: {members_invitable_by: 'admins'}

    #
    # DISCUSSIONS / COMMENTS
    can :show, Discussion, group: {viewable_by: 'everyone', archived_at: nil}
    can :show, Discussion, group: {viewable_by: 'members', archived_at: nil}, group_id: user.group_ids
    can :show, Discussion, group: {viewable_by: 'parent_group_members', archived_at: nil}, group: {parent_id: user.group_ids}
    can :show, Discussion, group: {viewable_by: 'parent_group_members', archived_at: nil}, group_id: user.group_ids

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
