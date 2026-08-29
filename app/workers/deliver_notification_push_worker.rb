class DeliverNotificationPushWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_delivery_id)
    delivery = claim(notification_delivery_id)
    return unless delivery

    subscription = delivery.recipient
    notification = delivery.notification
    unless subscription&.active?
      delivery.update!(status: "cancelled", last_error: nil)
      return
    end

    result = I18n.with_locale(subscription.user.locale) do
      WebPushService.deliver!(
        subscription: subscription,
        payload: PushPayloadService.for_notification(
          notification: notification,
          recipient: subscription.user
        )
      )
    end
    delivery.update!(
      status: result.nil? ? "cancelled" : "delivered",
      delivered_at: (Time.current unless result.nil?),
      last_error: nil
    )
  rescue StandardError => error
    delivery&.update!(status: "failed", last_error: error.message)
    raise
  end

  private

  def claim(notification_delivery_id)
    delivery = nil
    NotificationDelivery.transaction do
      delivery = NotificationDelivery.lock.find_by(id: notification_delivery_id)
      return unless delivery
      return unless delivery.channel == "push"
      return unless %w[pending failed].include?(delivery.status)

      now = Time.current
      delivery.update!(
        status: "claimed",
        claimed_at: now,
        last_attempt_at: now,
        attempt_count: delivery.attempt_count + 1
      )
    end
    delivery
  end
end
