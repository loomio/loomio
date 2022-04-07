class ChatbotService
  def self.create(chatbot:, actor:)
    actor.ability.authorize! :create, chatbot
    return false unless chatbot.valid?
    chatbot.save!
    publish_configs!
  end

  def self.update(chatbot:, params:, actor:)
    actor.ability.authorize! :update, chatbot
    params.delete(:access_token) unless params[:access_token].present?
    chatbot.assign_attributes(params)
    return false unless chatbot.valid?
    chatbot.save!
    publish_configs!
  end

  def self.destroy(chatbot:, actor:)
    actor.ability.authorize! :destroy, chatbot
    chatbot.destroy
  end

  def self.publish_event!(event)
    return unless Array(event.recipient_chatbot_ids).any?
    chatbots = event.eventable.group.chatbots
    MAIN_REDIS_POOL.with do |client|
      chatbots.where(id: event.recipient_chatbot_ids).each do |chatbot|
        # later, make a list and rpush into it. i guess
        template_name = event.eventable_type.tableize.singularize
        template_name = 'poll' if event.eventable_type == 'Outcome'
        template_name = 'group' if event.eventable_type == 'Membership'

        if %w[Poll Stance Outcome].include? event.eventable_type
          poll = event.eventable.poll 
        end

        client.publish("chatbot/publish", {
          chatbot_id: chatbot.id,
          payload: {
            html: ApplicationController.renderer.render(layout: nil, template: "matrix_bot/#{template_name}", assigns: { poll: poll, event: event } )
          }
        }.to_json)
      end
    end
  end

  def self.publish_configs!
    MAIN_REDIS_POOL.with do |client|
      client.del("chatbot/configs")
      config = Chatbot.all.map do |bot|
        client.hset("chatbot/configs", bot.id, bot.config.to_json)
      end
      client.publish("chatbot/configs_updated", true)
    end
  end

  def self.publish_config!(bot)
    MAIN_REDIS_POOL.with do |client|
      client.hset("chatbot/configs", bot.id, bot.config.to_json)
      client.publish("chatbot/new_config", bot.config.to_json)
    end
  end

  def self.publish_test!(params)
    MAIN_REDIS_POOL.with do |client|
      data = params.slice(:server, :access_token, :channel)
      data.merge!(message: I18n.t('webhook.hello', group: params[:group_name]))
      client.publish("chatbot/test", data.to_json)
    end
  end

  # def self.serialize(event, format)
  #   serializer = [
  #     "Webhook::#{format.classify}::#{event.kind.classify}Serializer",
  #     "Webhook::#{format.classify}::#{event.eventable.class}Serializer",
  #     "Webhook::#{format.classify}::BaseSerializer"
  #   ].detect { |str| str.constantize rescue nil }.constantize
  #   # serializer.new(event, root: false, scope: {webhook: webhook})
  #   serializer.new(event, root: false)
  # end
end
