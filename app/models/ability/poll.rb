module Ability::Poll
  def initialize(user)
    super(user)

    can :view_pending_invitations, ::Poll do |poll|
      can? :view_pending_invitations, poll.guest_group
    end

    can :make_draft, ::Poll do |poll|
      user.is_logged_in? && can?(:show, poll)
    end

    can :add_options, ::Poll do |poll|
      user_is_author_of?(poll) ||
      (user.can?(:vote_in, poll) && poll.voter_can_add_options)
    end

    can :vote_in, ::Poll do |poll|
      poll.active? && (poll.members.include?(user) || poll.anyone_can_participate)
    end

    can [:show, :toggle_subscription, :subscribe_to], ::Poll do |poll|
      poll.anyone_can_participate ||
      user_is_author_of?(poll) ||
      can?(:show, poll.discussion) ||
      poll.members.include?(user) ||
      poll.guest_group.memberships.pluck(:token).include?(user.membership_token)
    end

    can :create, ::Poll do |poll|
      user.email_verified? && (
        !poll.group.presence ||
        can?(:start_poll, poll.discussion) ||
        can?(:start_poll, poll.group)
      )
    end

    can [:update, :share, :remind, :destroy, :export, :announce], ::Poll do |poll|
      user_is_author_of?(poll) || user_is_admin_of?(poll.group_id)
    end

    can :close, ::Poll do |poll|
      poll.active? && (user_is_author_of?(poll) || user_is_admin_of?(poll.group_id))
    end

    can :reopen, ::Poll do |poll|
      poll.closed? && can?(:update, poll)
    end

  end
end
