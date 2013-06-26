class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    cannot :sign_up, User

    #
    # GROUPS
    #

    can :show, Group, :viewable_by => :everyone
    can :show, Group, :viewable_by => :members, :id => user.group_ids
    can :show, Group, :viewable_by => :parent_group_members,
                      :parent_id => user.group_ids
    can [:update, :email_members, :edit_privacy, :hide_next_steps], Group, :id => user.adminable_group_ids
    can :edit_description, Group, :id => user.group_ids
    can [:add_subgroup, :get_members], Group, :id => user.group_ids
    can :add_members, Group, :members_invitable_by => :members,
                             :id => user.group_ids
    can :add_members, Group, :members_invitable_by => :admins,
                             :id => user.adminable_group_ids
    can :archive, Group, :id => user.adminable_group_ids
    can [:create, :request_membership], Group

    #
    # MEMBERSHIPS
    #

    can :create, Membership
    can :cancel_request, Membership, :user => user

    can [:approve_request, :ignore_request], Membership do |membership|
      can? :add_members, membership.group
    end

    can [:make_admin, :remove_admin], Membership,
      :group_id => user.adminable_group_ids

    can :destroy, Membership, :user_id => user.id
    can :destroy, Membership, :group_id => user.adminable_group_ids
    cannot :destroy, Membership do |membership|
      (membership.group.users.size == 1) ||
      (membership.admin? and membership.group.admins.size == 1)
    end

    #
    # DISCUSSIONS / COMMENTS
    #

    can :index, Discussion
    can :destroy, Discussion, group_id: user.adminable_group_ids
    can :move, Discussion, group_id: user.adminable_group_ids
    can [:add_comment, :new_proposal, :create, :update_description, :edit_title, :show_description_history, :preview_version, :update_version], Discussion, :group_id => user.group_ids

    can :destroy, Comment, user_id: user.id
    can :destroy, Comment, :discussion => { group_id: user.adminable_group_ids }

    can [:like, :unlike], Comment, :discussion => { :id => user.discussion_ids }

    #
    # MOTIONS
    #
    can :get_and_clear_new_activity, Motion do |motion|
      can? :show, motion.group
    end
    can :create, Motion, :discussion_id => user.discussion_ids
    can [:edit, :update, :destroy, :close, :edit_outcome], Motion, :author_id => user.id
    can [:edit, :update, :destroy, :close, :edit_outcome], Motion,
      :discussion => { :group_id => user.adminable_group_ids }
  end
end
