module Ability::Stance
  def initialize(user)
    super(user)

    can :show, ::Stance do |stance|
      user.can?(:show, stance.poll)
    end

    can [:update], ::Stance do |stance|
      user.email_verified? && stance.participant == user && stance.latest?
    end

    can [:make_draft, :create], ::Stance do |stance|
      user.can? :vote_in, stance.poll
    end

    can :redeem, ::Stance do |stance|
      Stance.redeemable.exists?(stance.id)
    end
  end
end
