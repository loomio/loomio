module Ability::Outcome
  def initialize(user)
    super(user)

    can :show, ::Outcome do |outcome|
      can? :show, outcome.poll
    end

    can [:create, :update], ::Outcome do |outcome|
      !outcome.poll.active? &&
      (outcome.admins.exists?(user.id) || (outcome.group.members_can_edit_discussions && outcome.members.exists?(user.id)))
    end

    can [:announce], ::Outcome do |outcome|
      !outcome.poll.active? &&
      (outcome.admins.exists?(user.id) || (outcome.group.members_can_announce && outcome.members.exists?(user.id)))
    end

    can [:add_members], ::Outcome do |outcome|
      !outcome.poll.active? && outcome.members.exists?(user.id)
    end

    can [:add_guests], ::Outcome do |outcome|
      !outcome.poll.active? &&
      (outcome.admins.exists?(user.id) || (outcome.group.members_can_add_guests && outcome.members.exists?(user.id)))
    end
  end
end
