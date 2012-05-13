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

    can [:edit, :update, :add_user_tag, :delete_user_tag, :invite_member,
         :user_group_tags, :group_tags, :add_subgroup], Group do |group|
      group.can_be_edited_by? user
    end

    can [:create, :index, :request_membership], Group

    #
    # MEMBERSHIPS
    #

    can [:create, :edit], Membership

    can :update, Membership do |membership|
      if params[:membership]
        if params[:membership][:access_level] == 'member'
          membership.can_be_made_member_by? user
        elsif params[:membership][:access_level] == 'admin'
          membership.can_be_made_admin_by? user
        end
      end
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
