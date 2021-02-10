module Ability
  module Tag
    def initialize(user)
      super(user)

      can [:create, :update, :destroy], ::Tag do |tag|
        tag.group.members.exists? user.id
      end

      can :show, ::Tag do |tag|
        user.can? :show, tag.group
      end
    end
  end
end
