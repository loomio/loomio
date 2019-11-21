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
        discussion.guest_group.memberships.find_by(token: user.membership_token) ||
        discussion.anyone_can_participate ||
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

    can [:announce], ::Discussion do |discussion|
      user_is_admin_of?(discussion.group_id) ||
        (discussion.group.members_can_announce? && user_is_member_of?(discussion.group_id))
    end

    can [:update], ::Discussion do |discussion|
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

    can [:destroy, :move, :move_comments], ::Discussion do |discussion|
      user_is_author_of?(discussion) or user_is_admin_of?(discussion.group_id)
    end

    can :fork, ::Discussion do |discussion|
      Event.where(id: discussion.forked_event_ids).pluck(:discussion_id).uniq.length == 1 &&
      can?(:move, Event.find(discussion.forked_event_ids.last).discussion) &&
      can?(:move, discussion)
    end

    can [:set_volume,
         :show_description_history,
         :preview_version,
         :make_draft], ::Discussion do |discussion|
      discussion.members.include?(user)
    end

    can :remove_events, ::Discussion do |discussion|
      user_is_author_of?(discussion) || user_is_admin_of?(discussion.group_id)
    end

    can :start_poll, ::Discussion do |discussion|
      can?(:start_poll, discussion.group) || can?(:start_poll, discussion.guest_group)
    end
  end
end
