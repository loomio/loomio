module Ability::Stance
  def initialize(user)
    super(user)

    can :show, ::Stance do |stance|
      user.can?(:show, stance.poll)
    end

    can [:update], ::Stance do |stance|
      can?(:vote_in, stance.poll) &&
      stance.real_participant == user &&
      stance.latest?
    end

    can [:uncast], ::Stance do |stance|
      can?(:update, stance) && stance.cast_at.present?
    end
    
    can [:create], ::Stance do |stance|
      user.can? :vote_in, stance.poll
    end

    can :redeem, ::Stance do |stance|
      Stance.redeemable.exists?(stance.id)
    end

    can [:make_admin, :remove_admin, :resend, :remove], ::Stance do |stance|
      stance.poll.admins.exists?(user.id)
    end

  end
end
