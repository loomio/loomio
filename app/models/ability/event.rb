module Ability
  module Event
    def initialize(user)
      super(user)

      can [:pin, :unpin], ::Event do |event|
        topicable = event.topic&.topicable
        topicable && can?(:update, topicable)
      end
    end
  end
end
