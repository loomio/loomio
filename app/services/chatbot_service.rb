class ChatbotService
  def self.create(chatbot:, actor:)
    actor.ability.authorize! :create, chatbot
    return false unless chatbot.valid?
    chatbot.save!
  end

  def self.update(chatbot:, params:, actor:)
    actor.ability.authorize! :update, chatbot
    chatbot.assign_attributes(params)
    return false unless chatbot.valid?
    chatbot.save!
  end

  def self.destroy(chatbot:, actor:)
    actor.ability.authorize! :destroy, chatbot
    chatbot.destroy
  end

  def self.list_channels
  end

  def self.publish_poll
  end
end
