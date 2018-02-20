module Ability::Discussion
  def initialize(user)
    super(user)

    can [:show,
         :print,
         :dismiss,
         :subscribe_to], ::Discussion do |discussion|
      !discussion.group.archived_at && (
        discussion.public? ||
        discussion.members.include?(user) ||
        (discussion.group.parent_members_can_see_discussions? && user_is_member_of?(discussion.group.parent_id))
      )
    end

    can [:mark_as_read, :mark_as_seen], ::Discussion do |discussion|
      user.is_logged_in? && can?(:show, discussion)
    end

    can :update_version, ::Discussion do |discussion|
      user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
    end

    can :create, ::Discussion do |discussion|
      (user.email_verified? &&
       discussion.group.present? &&
       discussion.group.members_can_start_discussions? &&
       user_is_member_of?(discussion.group_id)) ||
      user_is_admin_of?(discussion.group_id)
    end

    can :update, ::Discussion do |discussion|
      user.email_verified? &&
      if discussion.group.members_can_edit_discussions?
        user_is_member_of?(discussion.group_id)
      else
        user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
      end
    end

    can :pin, ::Discussion do |discussion|
      user_is_admin_of?(discussion.group_id)
    end

    can [:destroy, :move], ::Discussion do |discussion|
      user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
    end

    can [:set_volume,
         :show_description_history,
         :preview_version,
         :make_draft], ::Discussion do |discussion|
      user_is_member_of?(discussion.group_id)
    end

    can :remove_events, ::Discussion do |discussion|
      user_is_author_of?(discussion) || user_is_admin_of?(discussion.group_id)
    end
  end
end
