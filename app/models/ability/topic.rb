module Ability::Topic
  def initialize(user)
    super(user)

    can [:show], ::Topic do |topic|
      can?(:show, topic.topicable)
    end
  end
end
