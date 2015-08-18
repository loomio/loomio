class WebhookService

  def self.publish!(webhook:, event:)
    return false unless webhook.event_types.include? event.kind
    HTTParty.post webhook.uri, body: payload_for(webhook, event), headers: webhook.headers
  end

  private

  def self.payload_for(webhook, event)
    WebhookSerializer.new(webhook_object_for(webhook, event), root: false).to_json
  end

  def self.webhook_object_for(webhook, event)
    "Webhooks::#{webhook.kind.classify}::#{event.kind.classify}".constantize.new(event)
  end

end
