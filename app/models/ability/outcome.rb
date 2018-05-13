module Ability::Outcome
  def initialize(user)
    super(user)

    can :show, ::Outcome do |outcome|
      can? :show, outcome.poll
    end

    can [:create, :update, :announce], ::Outcome do |outcome|
      !outcome.poll.active? &&
      user.ability.can?(:update, outcome.poll)
    end
  end
end
