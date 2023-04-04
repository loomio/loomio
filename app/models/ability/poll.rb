module Ability::Poll
  def initialize(user)
    super(user)

    can :add_options, ::Poll do |poll|
      user_is_author_of?(poll) || (user.can?(:vote_in, poll) && poll.voter_can_add_options)
    end

    can :vote_in, ::Poll do |poll|
      user.is_logged_in? &&
      poll.active? &&
      (
        poll.anyone_can_participate? ||
        poll.unmasked_voters.exists?(user.id) ||
        (!poll.specified_voters_only && poll.voters.exists?(user.id))
      )
    end

    can [:export], ::Poll do |poll|
      user.can?(:show, poll) && poll.show_results?
    end

    can [:show], ::Poll do |poll|
      Webhook.where(group_id: poll.group_id,
                    actor_id: user.id).where.any(permissions: 'show_poll').exists? ||
      PollQuery.visible_to(user: user, show_public: true).exists?(poll.id)
    end

    can [:create], ::Poll do |poll|
      # cannot use poll.admins for create, because it assumes poll exists in database
      (poll.group_id &&
        ((poll.group.admins.exists?(user.id) || # user is admin
         (poll.group.members_can_raise_motions && poll.group.members.exists?(user.id)) || # user is member
         (poll.group.members_can_raise_motions && poll.discussion.present? && poll.discussion.guests.exists?(user.id)) || # user is guest of thread
          Webhook.where(group_id: poll.group_id, actor_id: user.id).where.any(permissions: 'create_poll').exists?))) ||
      (poll.group_id.nil? && poll.discussion_id && poll.discussion.members.exists?(user.id)) ||
      (poll.group_id.nil? && poll.discussion_id.nil? && user.is_logged_in? && user.email_verified?)
    end

    can [:announce, :remind], ::Poll do |poll|
      if poll.group_id
        Webhook.where(group_id: poll.group_id, actor_id: user.id).where.any(permissions: 'create_poll').exists? ||
        poll.group.admins.exists?(user.id) ||
        (poll.group.members_can_announce && poll.admins.exists?(user.id)) ||
        (poll.group.members_can_announce && !poll.specified_voters_only && poll.members.exists?(user.id))
      else
        poll.admins.exists?(user.id) ||
        (!poll.specified_voters_only && poll.members.exists?(user.id)) 
      end
    end

    can [:add_voters, :add_members], ::Poll do |poll|
      poll.admins.exists?(user.id)
    end

    can [:add_guests], ::Poll do |poll|
      if poll.group_id
        poll.group.admins.exists?(user.id) ||
        (poll.group.members_can_add_guests && poll.admins.exists?(user.id))
      else
        poll.admins.exists?(user.id)
      end
    end

    can [:update], ::Poll do |poll|
      poll.admins.exists?(user.id) || (poll.wip? && poll.voters.exists?(user.id))
    end

    can [:destroy], ::Poll do |poll|
      poll.admins.exists?(user.id)
    end

    can :close, ::Poll do |poll|
      poll.active? && poll.admins.exists?(user.id)
    end

    can :reopen, ::Poll do |poll|
      poll.closed? && can?(:update, poll) && !poll.anonymous
    end
  end
end
