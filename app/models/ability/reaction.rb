module Ability::Reaction
  def initialize(user)
    super(user)

    can :show, ::Reaction do |reaction|
      can?(:show, reaction.reactable)
    end
    
    can :update, ::Reaction do |reaction|
      user.is_logged_in? && can?(:show, reaction.reactable)
    end

    can :destroy, ::Reaction do |reaction|
      user_is_author_of?(reaction)
    end
  end
end
