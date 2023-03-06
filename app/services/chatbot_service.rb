class ChatbotService
  def self.create(chatbot:, actor:)
    actor.ability.authorize! :create, chatbot
    return false unless chatbot.valid?
    chatbot.author = actor
    chatbot.save!
  end

  def self.update(chatbot:, params:, actor:)
    actor.ability.authorize! :update, chatbot
    params.delete(:access_token) unless params[:access_token].present?
    chatbot.assign_attributes(params)
    return false unless chatbot.valid?
    chatbot.save!
  end

  def self.destroy(chatbot:, actor:)
    actor.ability.authorize! :destroy, chatbot
    chatbot.destroy
  end

  def self.publish_event!(event_id)
    event = Event.find(event_id)
    event.reload
    return if event.eventable.nil?
    
    chatbots = event.eventable.group.chatbots

    CACHE_REDIS_POOL.with do |client|
      chatbots.where(id: event.recipient_chatbot_ids).
                  or(chatbots.where.any(event_kinds: event.kind)).each do |chatbot|
        # later, make a list and rpush into it. i guess
        template_name = event.eventable_type.tableize.singularize
        template_name = 'poll' if event.eventable_type == 'Outcome'
        template_name = 'group' if event.eventable_type == 'Membership'
        template_name = 'notification' if chatbot.notification_only

        if %w[Poll Stance Outcome].include? event.eventable_type
          poll = event.eventable.poll 
        end

        example_user = event.actor || chatbot.group.creator

        recipient = LoggedOutUser.new(locale: example_user.locale,
                                      time_zone: example_user.time_zone,
                                      date_time_pref: example_user.date_time_pref)
        I18n.with_locale(recipient.locale) do
          if chatbot.kind == "webhook"
            serializer = "Webhook::#{chatbot.webhook_kind.classify}::EventSerializer".constantize
            payload = serializer.new(event, root: false, scope: {template_name: template_name, recipient: recipient}).as_json
            req = Clients::Webhook.new.post(chatbot.server, params: payload)
            if req.response.code != 200
              Sentry.capture_message("chatbot id #{chatbot.id} post event id #{event.id} failed: code: #{req.response.code} body: #{req.response.body}")
            end
          else
            client.publish("chatbot/publish", {
              config: chatbot.config,
              payload: {
                html: ApplicationController.renderer.render(
                  layout: nil,
                  template: "chatbot/matrix/#{template_name}",
                  assigns: { poll: poll, event: event, recipient: recipient } )
              }
            }.to_json)
          end
        end
      end
    end
  end

  def self.publish_test!(params)
    case params[:kind]
    when 'slack_webhook'
      Clients::Webhook.new.post(params[:server], params: {text: I18n.t('chatbot.connection_test_successful')})
    else
      MAIN_REDIS_POOL.with do |client|
        data = params.slice(:server, :access_token, :channel)
        data.merge!(message: I18n.t('chatbot.connection_test_successful', group: params[:group_name]))
        client.publish("chatbot/test", data.to_json)
      end
    end
  end
end
