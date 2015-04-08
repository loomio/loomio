require 'rest-client'

class WebhookService

  def self.publish!(webhook:, event:)
    return false unless webhook.valid?
    RestClient.post webhook.uri,
                    serializer_for(webhook).new(event, root: false).to_json,
                    webhook.headers
  end

  private

  def self.serializer_for(event)
    "Webhooks::#{event.kind.classify}Serializer".constantize
  end

end