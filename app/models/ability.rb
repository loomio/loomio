class Ability
  include CanCan::Ability

  def initialize(user, params)

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
      group.can_invite_members? user
    end

    can [:create, :index, :request_membership], Group

    #
    # MEMBERSHIPS
    #

    can :create, Membership

    can :approve, Membership do |membership|
      membership.can_be_approved_by? user
    end

    can :make_admin, Membership do |membership|
      membership.can_be_made_admin_by? user
    end

    can :remove_admin, Membership do |membership|
      membership.can_have_admin_rights_revoked_by? user
    end

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

    can :create, Discussion do |discussion|
      group = Group.find(params[:discussion][:group_id])
      user.group_ids.include? group.id
    end

    can :destroy, Comment, user_id: user.id
    can [:like, :unlike], Comment, :discussion => { :id => user.discussion_ids }

  end
end
