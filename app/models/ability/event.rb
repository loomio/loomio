module Ability
  module Event
    def initialize(user)
      super(user)

      can [:pin, :unpin], ::Event do |event|
        event.discussion && user.ability.can?(:update, event.discussion)
      end
    end
  end
end
