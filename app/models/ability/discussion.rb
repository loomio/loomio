module Ability::Discussion
  def initialize(user)
    super(user)

    can [:show,
         :print,
         :dismiss,
         :subscribe_to], ::Discussion do |discussion|
      # do we want to support having a discussion_reader_token but not being logged in yet?
      DiscussionQuery.visible_to(user: user).exists?(discussion.id)
    end

    can [:mark_as_read, :mark_as_seen], ::Discussion do |discussion|
      user.is_logged_in? && can?(:show, discussion)
    end

    can :update_version, ::Discussion do |discussion|
      discussion.author == user or discussion.admins.exists?(user.id)
    end

    can :create, ::Discussion do |discussion|
      Webhook.where(group_id: discussion.group_id, actor_id: user.id).where.any(permissions: 'create_discussion').exists? ||
      user.email_verified? &&
      (
       discussion.group.blank? ||
       discussion.group.admins.exists?(user.id) ||
       (discussion.group.members_can_start_discussions && discussion.group.members.exists?(user.id))
      )
    end

    can [:announce], ::Discussion do |discussion|
      if discussion.group_id
        discussion.group.admins.exists?(user.id) ||
        (discussion.group.members_can_announce && discussion.members.exists?(user.id))
      else
        discussion.admins.exists?(user.id)
      end
    end

    can [:add_members], ::Discussion do |discussion|
      discussion.members.exists?(user.id)
    end

    can [:add_guests], ::Discussion do |discussion|
      if discussion.group_id
        discussion.group.admins.exists?(user.id) ||
        (discussion.group.members_can_add_guests && discussion.members.exists?(user.id))
      else
        !discussion.id || discussion.admins.exists?(user.id)
      end
    end

    can [:update, :move, :move_comments, :pin], ::Discussion do |discussion|
      discussion.discarded_at.nil? &&
      (discussion.author == user ||
      discussion.admins.exists?(user.id) ||
      (discussion.group.members_can_edit_discussions && discussion.members.exists?(user.id)))
    end

    can [:destroy, :discard], ::Discussion do |discussion|
      discussion.discarded_at.nil? &&
      (discussion.author == user || discussion.admins.exists?(user.id))
    end

    can :fork, ::Discussion do |discussion|
      Event.where(id: discussion.forked_event_ids).pluck(:discussion_id).uniq.length == 1 &&
      can?(:move, Event.find(discussion.forked_event_ids.last).discussion) &&
      can?(:move, discussion)
    end

    can [:set_volume], ::Discussion do |discussion|
      discussion.members.exists?(user.id)
    end

    can :remove_events, ::Discussion do |discussion|
      discussion.author == user or discussion.admins.exists?(user.id)
    end
  end
end
