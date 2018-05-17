module Ability::Stance
  def initialize(user)
    super(user)

    can :show, ::Stance do |stance|
      user.can?(:show, stance.poll)
    end

    can [:make_draft, :create, :announce], ::Stance do |stance|
      user.can? :vote_in, stance.poll
    end

    can [:verify, :destroy], ::Stance do |stance|
      user.email_verified? &&
      stance.participant.email_verified == false &&
      stance.participant.email == user.email
    end
  end
end
