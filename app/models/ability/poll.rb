module Ability::Poll
  def initialize(user)
    super(user)

    can :vote_in, ::Poll do |poll|
      user.is_logged_in? &&
      poll.active? &&
      (
        poll.unmasked_voters.exists?(user.id) ||
        (!poll.specified_voters_only && poll.members.exists?(user.id))
      )
    end

    can [:export], ::Poll do |poll|
      user.can?(:show, poll) && poll.show_results?
    end

    can :receipts, ::Poll do |poll|
      if AppConfig.app_features[:verify_participants_admin_only]
        poll.group_id && poll.group.admins.exists?(user.id)
      else
        user.can?(:show, poll)
      end
    end

    can [:show], ::Poll do |poll|
      PollQuery.visible_to(user: user).exists?(poll.id)
    end

    can [ :create ], ::Poll do |poll|
      topic = poll.topic
      group = topic.group
      !group.archived_at &&
      !topic.closed_at &&
      (poll.poll_template_id.nil? || poll.poll_template.public? || user.group_ids.include?(poll.poll_template.group_id)) &&
      (group.admins_include?(user) || (group.members_can_raise_motions && group.members_include?(user))) ||
      (topic.admins_include?(user) || (topic.members_can_raise_motions && topic.members_include?(user)))
    end

    can [ :announce ], ::Poll do |poll|
      topic = poll.topic
      group = topic.group
      if topic.group_id
        group.admins.exists?(user.id) || (group.members_can_announce && topic.admins.exists?(user.id))
      else
        topic.admins.exists?(user.id) || (!poll.specified_voters_only && topic.members.exists?(user.id))
      end
    end

    can [ :remind ], ::Poll do |poll|
      poll.opened? &&
      if poll.group_id
        poll.group.admins.exists?(user.id) ||
        (poll.group.members_can_announce && poll.admins.exists?(user.id))
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
        Subscription.for(poll.group).allow_guests &&
        (poll.group.admins.exists?(user.id) || (poll.group.members_can_add_guests && poll.admins.exists?(user.id)))
      else
        poll.admins.exists?(user.id)
      end
    end

    can [:update], ::Poll do |poll|
      !poll.topic&.closed_at &&
      poll.admins.exists?(user.id) && !poll.closed?
    end

    can [:destroy], ::Poll do |poll|
      !poll.topic&.closed_at &&
      poll.admins.exists?(user.id)
    end

    can :close, ::Poll do |poll|
      poll.active? &&
      poll.admins.exists?(user.id)
    end

    can :reopen, ::Poll do |poll|
      poll.closed? &&
      !poll.anonymous &&
      !poll.topic&.closed_at &&
      poll.admins.exists?(user.id)
    end
  end
end
