class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new

    #
    # USERS
    #

    cannot :sign_up, User

    #
    # GROUPS
    #

    can [:update, :add_subgroup], Group, :id => user.adminable_group_ids

    can :add_members, Group do |group|
      if group.members_invitable_by == :members
        true if user.groups.include?(group)
      elsif group.members_invitable_by == :admins
        true if user.adminable_groups.include?(group)
      end
    end

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

    can :destroy, Membership do |membership|
      membership.can_be_deleted_by? user
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

  end
end
