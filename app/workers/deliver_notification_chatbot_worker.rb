# Deliver the chatbot row assigned to this job. Solid Queue owns retry and failure history.
class DeliverNotificationChatbotWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_delivery_id)
    delivery = NotificationDelivery.find_by(id: notification_delivery_id, channel: "chatbot")
    return unless delivery
    return if delivery.delivered_at?

    ChatbotService.publish_notification_delivery!(delivery.id)
    delivery.update!(delivered_at: Time.current)
  end

end
