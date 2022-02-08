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

  def self.test(chatbot:, actor:)
    actor.ability.authorize! :test, chatbot
    chatbot.client.post_message('webhook.test_message', group: chatbot.group.name)
  end

  def self.list_channels
  end

  def self.publish_poll
  end

  def serialized_event(event, format, webhook)
    serializer = [
      "Webhook::#{format.classify}::#{event.kind.classify}Serializer",
      "Webhook::#{format.classify}::#{event.eventable.class}Serializer",
      "Webhook::#{format.classify}::BaseSerializer"
    ].detect { |str| str.constantize rescue nil }.constantize
    serializer.new(event, root: false, scope: {webhook: webhook}).as_json
  end
end
