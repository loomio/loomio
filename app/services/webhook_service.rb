class WebhookService
  def self.create(webhook:, actor:)
    actor.ability.authorize! :create, webhook

    return false unless webhook.valid?
    webhook.save!

    webhook.client.publish_created!
  end

  def self.destroy(webhook:, actor:)
    actor.ability.authorize! :destroy, webhook
    webhook.destroy
  end
end
