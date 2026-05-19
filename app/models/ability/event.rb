module Ability
  module Event
    def initialize(user)
      super(user)

      can [:pin, :unpin], ::Event do |event|
        can?(:update, event.topic)
      end
    end
  end
end
