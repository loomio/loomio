class WebPushService
  def self.send_notification(subscription, event)
    return unless subscription && event
    
    message = build_message(event)
    
    begin
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
      # Subscription is no longer valid, delete it
      subscription.destroy
    rescue => e
      # Log error but don't fail the notification
      Rails.logger.error("WebPush error: #{e.message}")
    end
  end

  private

  def self.build_message(event)
    I18n.with_locale(event.user.locale) do
      {
        title: notification_title(event),
        body: notification_body(event),
        icon: event.user.avatar_url,
        badge: '/favicon.ico',
        tag: "event-#{event.id}",
        data: {
          url: notification_url(event),
          event_id: event.id
        }
      }
    end
  end

  def self.notification_title(event)
    I18n.t("notifications.#{event.kind}.title", **event.notification_translation_values)
  rescue
    event.eventable.title rescue "Loomio"
  end

  def self.notification_body(event)
    I18n.t("notifications.#{event.kind}.body", **event.notification_translation_values)
  rescue
    I18n.t("notifications.#{event.kind}.title", **event.notification_translation_values)
  rescue
    ""
  end

  def self.notification_url(event)
    polymorphic_url(event.eventable) rescue "/"
  end
end
