class Ability
  include CanCan::Ability

  def initialize(user, params)

    #
    # GROUPS
    #

    can [:edit, :update, :add_user_tag, :delete_user_tag, :invite_member,
         :user_group_tags, :group_tags], Group do |group|
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

    can :add_comment, Discussion do |discussion|
      discussion.can_add_comment? user
    end

    can :destroy, Comment, user_id: user.id

  end
end
