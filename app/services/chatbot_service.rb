class ChatbotService
  REQUEST_TIMEOUT_SECONDS = 5

  def self.create(chatbot:, actor:)
    actor.ability.authorize! :create, chatbot
    unless chatbot.valid?
      Sentry.metrics.count("chatbot.create_failed", attributes: { columns: chatbot.errors.attribute_names.join(',') })
      return false
    end
    chatbot.author = actor
    chatbot.save!
    Sentry.metrics.count("chatbot.create", attributes: { kind: chatbot.kind })
  end

  def self.update(chatbot:, params:, actor:)
    actor.ability.authorize! :update, chatbot
    params.delete(:access_token) unless params[:access_token].present?
    chatbot.assign_attributes(params.except(:group_id))
    unless chatbot.valid?
      Sentry.metrics.count("chatbot.update_failed", attributes: { columns: chatbot.errors.attribute_names.join(',') })
      return false
    end
    chatbot.save!
    Sentry.metrics.count("chatbot.update", attributes: { kind: chatbot.kind })
  end

  def self.destroy(chatbot:, actor:)
    actor.ability.authorize! :destroy, chatbot
    Sentry.metrics.count("chatbot.destroy", attributes: { kind: chatbot.kind })
    chatbot.destroy
  end

  def self.publish_topic_item!(topic_item_id)
    return unless topic_item = TopicItem.find_by(id: topic_item_id)
    topic_item.reload
    return if topic_item.itemable.nil?
    return if topic_item.itemable.is_a?(Stance) && !topic_item.itemable.shared_update_visible?

    chatbots = topic_item.itemable.topic.group.chatbots

    chatbots.where(id: topic_item.recipient_chatbot_ids).
                or(chatbots.where("? = ANY(chatbots.event_kinds)", topic_item.kind)).each do |chatbot|
      publish_to_chatbot!(topic_item: topic_item, chatbot: chatbot)
    end
  end

  def self.publish_notification_delivery!(notification_delivery_id)
    delivery = NotificationDelivery.find_by!(
      id: notification_delivery_id,
      channel: "chatbot",
      recipient_type: "Chatbot"
    )
    topic_item = NotificationRenderingContext.new(delivery.notification)

    publish_to_chatbot!(topic_item: topic_item, chatbot: delivery.recipient)
  end

  MATRIX_COMPONENTS = {
    'poll'         => Views::Chatbot::Matrix::Poll,
    'comment'      => Views::Chatbot::Matrix::Comment,
    'discussion'   => Views::Chatbot::Matrix::Discussion,
    'notification' => Views::Chatbot::Matrix::Notification
  }.freeze

  MARKDOWN_COMPONENTS = {
    'poll'         => Views::Chatbot::Markdown::Poll,
    'discussion'   => Views::Chatbot::Markdown::Discussion,
    'comment'      => Views::Chatbot::Markdown::Comment,
    'stance'       => Views::Chatbot::Markdown::Stance,
    'notification' => Views::Chatbot::Markdown::Notification
  }.freeze

  SLACK_COMPONENTS = {
    'poll'         => Views::Chatbot::Slack::Poll,
    'discussion'   => Views::Chatbot::Slack::Discussion,
    'comment'      => Views::Chatbot::Slack::Comment,
    'stance'       => Views::Chatbot::Slack::Stance,
    'notification' => Views::Chatbot::Slack::Notification
  }.freeze

  def self.matrix_component(template_name, topic_item:, poll:, recipient:)
    klass = MATRIX_COMPONENTS[template_name] || MATRIX_COMPONENTS['notification']
    klass.new(topic_item: topic_item, poll: poll, recipient: recipient)
  end

  def self.markdown_component(template_name, topic_item:, poll:, recipient:)
    klass = MARKDOWN_COMPONENTS[template_name] || MARKDOWN_COMPONENTS['notification']
    klass.new(topic_item: topic_item, poll: poll, recipient: recipient)
  end

  def self.slack_component(template_name, topic_item:, poll:, recipient:)
    klass = SLACK_COMPONENTS[template_name] || SLACK_COMPONENTS['notification']
    klass.new(topic_item: topic_item, poll: poll, recipient: recipient)
  end

  def self.publish_to_chatbot!(topic_item:, chatbot:)
    template_name = topic_item.itemable_type.tableize.singularize
    template_name = 'poll' if topic_item.itemable_type == 'Outcome'
    template_name = 'group' if topic_item.itemable_type == 'Membership'
    template_name = 'notification' if chatbot.notification_only

    poll = topic_item.itemable.poll if %w[Poll Stance Outcome].include? topic_item.itemable_type
    example_user = chatbot.author || chatbot.group.creator
    recipient = LoggedOutUser.new(locale: example_user.locale,
                                  time_zone: example_user.time_zone,
                                  date_time_pref: example_user.date_time_pref)

    Sentry.metrics.count("chatbot.notify", attributes: { kind: chatbot.kind, event_kind: topic_item.kind })
    I18n.with_locale(recipient.locale) do
      if chatbot.kind == "webhook"
        serializer = "Webhook::#{chatbot.webhook_kind.classify}::TopicItemSerializer".constantize
        payload = serializer.new(
          topic_item,
          root: false,
          scope: { template_name: template_name, recipient: recipient }
        ).as_json
        response = deliver_webhook(chatbot.server, payload)
        unless response.is_a?(Net::HTTPSuccess)
          Sentry.capture_message(
            "chatbot id #{chatbot.id} post #{topic_item.class.name} id #{topic_item.id} failed: " \
            "code: #{response&.code} body: #{response&.body}"
          )
        end
      else
        component = matrix_component(template_name, topic_item: topic_item, poll: poll, recipient: recipient)
        html = ApplicationController.renderer.render(component, layout: false)
        matrix_client = Clients::Matrix.new(server: chatbot.server, access_token: chatbot.access_token)
        matrix_client.send_html(chatbot.channel, html)
      end
    end
  end
  private_class_method :publish_to_chatbot!

  def self.publish_test!(params)
    validate_public_server!(params[:server])

    case params[:kind]
    when 'slack_webhook'
      deliver_webhook(params[:server], { text: I18n.t('chatbot.connection_test_successful') })
    else
      matrix_client = Clients::Matrix.new(server: params[:server], access_token: params[:access_token])
      message = I18n.t('chatbot.connection_test_successful', group: params[:group_name])
      matrix_client.send_text(params[:channel], message)
    end
  end

  def self.validate_public_server!(server)
    raise CanCan::AccessDenied unless SafeHttpService.safe_to_fetch?(server)
  end

  # Deliver a webhook payload through the SSRF-guarded, IP-pinned client. The
  # chatbot.server URL is user-controlled and only validated at save time, so
  # every send must re-resolve-and-pin to defeat DNS rebinding / redirects.
  # Returns a Net::HTTPResponse or nil.
  def self.deliver_webhook(url, payload)
    SafeHttpService.pinned_request(:post, url,
      headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: payload.to_json,
      timeout: REQUEST_TIMEOUT_SECONDS)
  end
end
