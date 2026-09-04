class DeliverNotificationPushWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_delivery_id)
    delivery = NotificationDelivery.find_by(id: notification_delivery_id, channel: "push")
    return unless delivery
    return if delivery.delivered_at?

    recipient = delivery.recipient
    notification = delivery.notification
    return unless recipient&.active?

    result = case recipient
    when PushSubscription
      I18n.with_locale(recipient.user.locale) do
        WebPushService.deliver!(
          subscription: recipient,
          payload: PushPayloadService.for_notification(
            notification: notification,
            recipient: recipient.user
          )
        )
      end
    when MobilePushRegistration
      Mobile::RelayService.deliver!(
        registration: recipient,
        event_id: Mobile::RelayService.event_id_for(delivery.id),
        kind: "notification"
      )
    else
      false
    end
    delivery.update!(delivered_at: Time.current) if result
  end
end
