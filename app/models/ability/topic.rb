module Ability::Topic
  def initialize(user)
    super(user)

    can [:show], ::Topic do |topic|
      can?(:show, topic.topicable)
    end

    can [:update, :move], ::Topic do |topic|
      topic.admins_include?(user)
    end
  end
end
