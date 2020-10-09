module Ability::Poll
  def initialize(user)
    super(user)

    can :add_options, ::Poll do |poll|
      user_is_author_of?(poll) || (user.can?(:vote_in, poll) && poll.voter_can_add_options)
    end

    can :vote_in, ::Poll do |poll|
      user.is_logged_in? &&
      poll.active? &&
      poll.anyone_can_participate? ||
      poll.voters.exists?(user.id) ||
      (!poll.specified_voters_only && poll.members.exists?(user.id))
    end

    can [:show, :toggle_subscription, :subscribe_to, :export], ::Poll do |poll|
      PollQuery.visible_to(user: user, show_public: true).exists?(poll.id)
    end

    can :create, ::Poll do |poll|
      user.email_verified? &&
      (poll.group.admins.exists?(user.id) ||
      (poll.group.members_can_raise_motions && poll.group.members.exists?(user.id)) ||
      !poll.group.presence)
    end

    can [:invite, :announce], ::Poll do |poll|
      if poll.discussion
        can?(:announce, poll.discussion)
      else
        poll.author == user || poll.admins.exists?(user.id)
      end
    end

    can [:update, :share, :remind, :destroy], ::Poll do |poll|
      poll.author == user || poll.admins.exists?(user.id)
    end

    can :close, ::Poll do |poll|
      poll.active? && poll.author == user || poll.admins.exists?(user.id)
    end

    can :reopen, ::Poll do |poll|
      poll.closed? && can?(:update, poll)
    end

  end
end
