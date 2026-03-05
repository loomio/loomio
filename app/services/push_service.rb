class PushService
  include PrettyUrlHelper

  def self.send_notification(subscription_id, event_id)
    subscription = PushSubscription.find_by(id: subscription_id)
    event = Event.find_by(id: event_id)
    return unless subscription && event

    new.deliver(subscription, event)
  end

  def deliver(subscription, event)
    message = build_message(subscription.user, event)

    WebPush.payload_send(
      message: message.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        subject: "mailto:#{ENV['REPLY_HOSTNAME']}",
        public_key: ENV['VAPID_PUBLIC_KEY'],
        private_key: ENV['VAPID_PRIVATE_KEY']
      }
    )
  rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription
    subscription.destroy
  rescue => e
    Rails.logger.error("WebPush error: #{e.message}")
  end

  private

  def build_message(recipient, event)
    I18n.with_locale(recipient.locale) do
      {
        title: notification_title(event),
        body: notification_body(event),
        icon: event.user&.avatar_url,
        badge: '/favicon.ico',
        tag: "event-#{event.id}",
        data: {
          url: notification_url(event),
          event_id: event.id
        }
      }
    end
  end

  def notification_title(event)
    event.eventable.title
  rescue
    "Loomio"
  end

  def notification_body(event)
    values = event.respond_to?(:notification_translation_values) ? event.notification_translation_values : {}
    key = values[:title] ? "notifications.with_title.#{event.kind}" : "notifications.without_title.#{event.kind}"
    result = I18n.t(key, default: nil, **values)
    result || notification_title(event)
  end

  def notification_url(event)
    polymorphic_path(event.eventable)
  rescue
    "/"
  end
end
