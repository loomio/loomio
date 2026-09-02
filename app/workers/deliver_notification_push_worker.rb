class DeliverNotificationPushWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_delivery_id)
    delivery = NotificationDelivery.find_by(id: notification_delivery_id, channel: "push")
    return unless delivery
    return if delivery.delivered_at?

    subscription = delivery.recipient
    notification = delivery.notification
    return unless subscription&.active?

    result = I18n.with_locale(subscription.user.locale) do
      WebPushService.deliver!(
        subscription: subscription,
        payload: PushPayloadService.for_notification(
          notification: notification,
          recipient: subscription.user
        )
      )
    end
    delivery.update!(delivered_at: Time.current) if result
  end

end
