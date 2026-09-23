module Ability
  module TopicItem
    def initialize(user)
      super(user)

      can [:pin, :unpin], ::TopicItem do |topic_item|
        can?(:update, topic_item.topic)
      end
    end
  end
end
