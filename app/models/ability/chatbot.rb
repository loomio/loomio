module Ability::Chatbot
  def initialize(user)
    super(user)

    can [:create, :destroy, :update], ::Chatbot do |chatbot|
      chatbot.group.admins.exists?(user.id)
    end
  end
end
