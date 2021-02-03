module Ability
  module Event
    def initialize(user)
      super(user)

      can [:pin, :unpin], ::Event do |event|
        event.discussion && can?(:update, event.discussion)
      end
    end
  end
end
