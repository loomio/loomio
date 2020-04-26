class WebhookService
  def self.create(webhook:, actor:)
    actor.ability.authorize! :create, webhook
    return false unless webhook.valid?
    webhook.save!
  end

  def self.update(webhook:, params:, actor:)
    actor.ability.authorize! :update, webhook
    webhook.assign_attributes(params)
    return false unless webhook.valid?
    webhook.save!
  end

  def self.destroy(webhook:, actor:)
    actor.ability.authorize! :destroy, webhook
    webhook.destroy
  end
end
