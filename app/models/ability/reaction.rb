module Ability::Reaction
  def initialize(user)
    super(user)

    can :update, ::Reaction do |reaction|
      user_is_member_of?(reaction.reactable.group.id)
    end

    can :destroy, ::Reaction do |reaction|
      user_is_author_of?(reaction)
    end
  end
end
