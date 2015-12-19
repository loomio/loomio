class MessageChannelService
  class AccessDeniedError < StandardError; end
  class UnknownChannelError < StandardError; end

  def self.subscribe_to(user:, model:)
    return unless ensure_valid_channel(model)
    raise AccessDeniedError.new unless user.ability.can?(:subscribe_to, model)
    PrivatePub.subscription(channel: model.message_channel, server: Rails.application.secrets.faye_url)
  end

  def self.publish(data, to:)
    return unless ensure_valid_channel(to)
    if ENV['DELAY_FAYE']
      PrivatePub.delay(priority: 10).publish_to(to.message_channel, data)
    else
      PrivatePub.publish_to(to.message_channel, data)
    end
  end

  def self.ensure_valid_channel(model)
    return unless model
    raise UnknownChannelError.new unless model.respond_to?(:message_channel)
    Rails.application.secrets.faye_url.present?
  end
end
