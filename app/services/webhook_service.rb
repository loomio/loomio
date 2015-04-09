require 'rest-client'

class WebhookService

  def self.publish!(webhook:, event:)
    return false unless webhook.event_types.include? event.kind
    RestClient.post webhook.uri,
                    payload_for(webhook, event),
                    webhook.headers
  end

  private

  def self.payload_for(webhook, event)
    serializer_for(webhook).new(event, root: false).to_json
  end

  def self.serializer_for(webhook)
    "Webhooks::#{webhook.kind.classify}Serializer".constantize
  end

end