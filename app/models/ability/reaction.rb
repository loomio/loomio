module Ability::Reaction
  def initialize(user)
    super(user)

    can :show, ::Reaction do |reaction|
      can?(:show, reaction.reactable)
    end

    # Reacting is taking part, so it needs thread membership, as commenting
    # does. Locked threads pause new activity.
    can :update, ::Reaction do |reaction|
      topic = reaction.reactable.topic
      user.is_logged_in? &&
      can?(:show, reaction.reactable) && topic.allow_reactions && !topic.locked_at &&
      topic.members_include?(user)
    end

    can :destroy, ::Reaction do |reaction|
      user_is_author_of?(reaction)
    end
  end
end
