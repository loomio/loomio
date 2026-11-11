module Ability::Outcome
  def initialize(user)
    super(user)

    can :show, ::Outcome do |outcome|
      can? :show, outcome.poll
    end

    # Outcomes conclude a vote, so they need a closed poll that still exists,
    # in a thread that is not locked.
    can [:create, :update], ::Outcome do |outcome|
      outcome.poll.closed? && outcome.poll.kept? && !outcome.poll.topic.locked_at &&
      (outcome.admins.exists?(user.id) || (outcome.group.members_can_edit_discussions && outcome.members.exists?(user.id)))
    end

    can [:announce], ::Outcome do |outcome|
      !outcome.poll.active? && can?(:announce, outcome.poll)
    end

    can [:add_members], ::Outcome do |outcome|
      !outcome.poll.active? && can?(:add_members, outcome.poll.topic)
    end

    can [:add_guests], ::Outcome do |outcome|
      !outcome.poll.active? && can?(:add_guests, outcome.poll.topic)
    end
  end
end
