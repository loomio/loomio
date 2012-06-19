class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    cannot :sign_up, User

    #
    # GROUPS
    #

    can :show, Group, :viewable_by => :everyone
    can :show, Group, :viewable_by => :members, :users => { :id => user.id }
    can :show, Group, :viewable_by => :parent_group_members,
                      :parent => { :users => { :id => user.id } }

    can :update, Group, :id => user.adminable_group_ids

    can :add_subgroup, Group, :id => user.group_ids

    can :add_members, Group, :members_invitable_by => :members,
                             :users => { :id => user.id }
    can :add_members, Group, :members_invitable_by => :admins,
                             :admins => { :id => user.id }

    can [:create, :index, :request_membership], Group

    #
    # MEMBERSHIPS
    #

    can :create, Membership

    can :cancel_request, Membership, :user => user

    can [:approve_request, :ignore_request], Membership do |membership|
      can? :add_members, membership.group
    end

    can [:make_admin, :remove_admin], Membership,
      :group => { :id => user.adminable_group_ids }

    can :destroy, Membership, :user_id => user.id
    can :destroy, Membership, :group => { :admins => { :id => user.id } }
    cannot :destroy, Membership do |membership|
      (membership.group.users.size == 1) ||
      (membership.admin? and membership.group.admins.size == 1)
    end

    #
    # DISCUSSIONS / COMMENTS
    #

    can :new_proposal, Discussion do |discussion|
      discussion.can_have_proposal_created_by? user
    end

    can :add_comment, Discussion do |discussion|
      discussion.can_be_commented_on_by? user
    end

    can :create, Discussion, :group => { :id => user.group_ids }

    can :destroy, Comment, user_id: user.id

    can [:like, :unlike], Comment, :discussion => { :id => user.discussion_ids }

    #
    # MOTIONS
    #

    can :create, Motion, :discussion => { :id => user.discussion_ids }

    can :update, Motion, :author => { :id => user.id }

    can [:destroy, :close_voting, :open_voting], Motion, :author_id => user.id
    can [:destroy, :close_voting, :open_voting], Motion,
      :discussion => { :group => { :admins => { :id => user.id } } }

    can :show, Motion do |motion|
      can? :show, motion.group
    end
  end
end
