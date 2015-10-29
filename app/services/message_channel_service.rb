class MessageChannelService
  class AccessDeniedError < StandardError
  end

  class UnknownChannelError < StandardError
  end

  def self.subscribe_to(user:, model:)
    raise AccessDeniedError.new unless can_subscribe?(user: user, model: model)
    PrivatePub.subscription(channel: channel_for(model), server: Rails.application.secrets.faye_url)
  end

  def self.can_subscribe?(user:, model:)
    case model
    when Group      then user.ability.can? :see_private_content, model
    when Discussion then user.ability.can? :show, model
    when User       then user.ability.can? :see_notifications_for, model
    else                 raise UnknownChannelError.new
    end
  end

  def self.channel_for(model)
    return unless [Group, Discussion, User].include? model.class
    "/#{model.class.to_s.downcase}-#{model.key}"
  end

  def self.publish(data, to:)
    return unless Rails.application.secrets.faye_url.present? && channel = channel_for(to)
    if ENV['DELAY_FAYE']
      PrivatePub.delay(priority: 10).publish_to(channel, data)
    else
      PrivatePub.publish_to(channel, data)
    end
  end
end
