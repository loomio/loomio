module Ability::Poll
  def initialize(user)
    super(user)

    can :make_draft, ::Poll do |poll|
      user.is_logged_in? && can?(:show, poll)
    end

    can :add_options, ::Poll do |poll|
      user_is_author_of?(poll) || (user.can?(:vote_in, poll) && poll.voter_can_add_options)
    end

    can :vote_in, ::Poll do |poll|
      poll.active? &&
      (poll.anyone_can_participate ||
      (poll.group.members_can_vote && poll.members.exists?(user.id)) ||
      poll.admins.exists?(user.id))
    end

    can [:show, :toggle_subscription, :subscribe_to], ::Poll do |poll|
      PollQuery.visible_to(user: user, show_public: true).exists?(poll.id)
      # poll.anyone_can_participate ||
      # user_is_author_of?(poll) ||
      # can?(:show, poll.discussion) ||
      # poll.members.exists?(user.id) ||
      # poll.stances.find_by(token: user.stance_token)
    end

    can :create, ::Poll do |poll|
      user.email_verified? &&
      (poll.admins.exists?(user.id) ||
      (poll.group.members_can_raise_motions && poll.members.exists?(user.id)) ||
      !poll.group.presence)
    end

    can [:invite, :announce], ::Poll do |poll|
      if poll.discussion
        can?(:announce, poll.discussion)
      else
        poll.author == user || poll.admins.exists?(user.id)
      end
    end

    can [:update, :share, :remind, :destroy, :export], ::Poll do |poll|
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
