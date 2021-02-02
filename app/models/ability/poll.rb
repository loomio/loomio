module Ability::Poll
  def initialize(user)
    super(user)

    can :add_options, ::Poll do |poll|
      poll.admins.exists?(user.id) || (user.can?(:vote_in, poll) && poll.voter_can_add_options)
    end

    can :vote_in, ::Poll do |poll|
      user.is_logged_in? &&
      poll.active? &&
      (
        poll.anyone_can_participate? ||
        poll.voters.exists?(user.id) ||
        (!poll.specified_voters_only && poll.members.exists?(user.id))
      )
    end

    can [:show, :export], ::Poll do |poll|
      PollQuery.visible_to(user: user, show_public: true).exists?(poll.id)
    end

    can [:create], ::Poll do |poll|
      Webhook.where(group_id: poll.group_id, actor_id: user.id).where.any(permissions: 'create_poll').exists? ||
      (
        (poll.group_id.nil? && poll.discussion_id.nil?) ||
        poll.admins.exists?(user.id) ||
        (poll.group.members_can_raise_motions && poll.members.exists?(user.id))
      )
    end

    can [:announce, :remind], ::Poll do |poll|
      if poll.group_id
        poll.group.admins.exists?(user.id) ||
        (poll.group.members_can_announce && can?(:update, poll))
      else
        poll.admins.exists?(user.id)
      end
    end

    can [:add_guests], ::Poll do |poll|
      if poll.group_id
        poll.group.admins.exists?(user.id) ||
        (poll.group.members_can_add_guests && poll.group.members_can_edit_polls && can?(:vote_in, poll))
      else
        poll.admins.exists?(user.id)
      end
    end

    can [:update, :add_members], ::Poll do |poll|
      poll.admins.exists?(user.id) ||
      (poll.group.members_can_edit_polls && can?(:vote_in, poll)) ||
      (poll.wip? && poll.members.exists?(user.id))
    end

    can :close, ::Poll do |poll|
      poll.active? && can?(:update, poll)
    end

    can :reopen, ::Poll do |poll|
      poll.closed? && !poll.anonymous && can?(:update, poll)
    end

    can [:destroy], ::Poll do |poll|
      poll.admins.exists?(user.id) ||
      (poll.group.members_can_edit_polls && can?(:vote_in, poll))
    end
  end
end
