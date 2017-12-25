module Ability::Poll
  def initialize(user)
    super(user)

    can :view_pending_invitations, ::Poll do |poll|
      can? :view_pending_invitations, poll.guest_group
    end

    can :view_shareable_invitation, ::Poll do |poll|
      can? :view_shareable_invitation, poll.guest_group
    end

    can :make_draft, ::Poll do |poll|
      user.is_logged_in? && can?(:show, poll)
    end

    can :add_options, ::Poll do |poll|
      user_is_author_of?(poll) ||
      (user.can?(:vote_in, poll) && poll.voter_can_add_options)
    end

    can :vote_in, ::Poll do |poll|
      # cant have a token of a verified user, and be logged in as another user
      poll.active? && (
        poll.members.include?(user) ||
        poll.anyone_can_participate ||
        poll.invitations.useable.find_by(token: user.token)
      )
    end

    can [:show, :toggle_subscription, :subscribe_to], ::Poll do |poll|
      poll.anyone_can_participate ||
      user_is_author_of?(poll) ||
      can?(:show, poll.discussion) ||
      poll.members.include?(user) ||
      poll.invitations.useable.pluck(:token).include?(user.token)
    end

    can :create, ::Poll do |poll|
      user.email_verified? &&
      (!poll.group.presence || poll.group.members.include?(user))
    end

    can [:update, :share, :remind, :destroy], ::Poll do |poll|
      user_is_author_of?(poll) || user_is_admin_of?(poll.group_id)
    end

    can :close, ::Poll do |poll|
      poll.active? && (user_is_author_of?(poll) || user_is_admin_of?(poll.group_id))
    end
  end
end
