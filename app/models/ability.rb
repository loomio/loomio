class Ability
  include CanCan::Ability

  def initialize(user, params)

    #
    # USERS
    #

    cannot :sign_up, User

    #
    # GROUPS
    #

    can [:edit, :update, :add_subgroup], Group do |group|
      group.can_be_edited_by? user
    end

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
      group.users.include?(user)
    end

    can :destroy, Comment, user_id: user.id
    can [:like, :unlike], Comment do |comment|
      comment.can_be_liked_by? user
    end

  end
end
