# Claim one chatbot delivery and render it from the notification-backed context.
class DeliverNotificationChatbotWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_delivery_id)
    delivery = claim(notification_delivery_id)
    return unless delivery

    ChatbotService.publish_notification_delivery!(delivery.id)
    delivery.update!(status: "delivered", delivered_at: Time.current, last_error: nil)
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
      return unless delivery.channel == "chatbot"
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
