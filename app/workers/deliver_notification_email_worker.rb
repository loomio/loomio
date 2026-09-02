# Deliver the email row assigned to this job. Solid Queue owns retry and failure history.
class DeliverNotificationEmailWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_delivery_id)
    delivery = NotificationDelivery.find_by(id: notification_delivery_id, channel: "email")
    return unless delivery
    return if delivery.delivered_at?

    NotificationMailer.notification(delivery.id).deliver_now
    delivery.update!(delivered_at: Time.current)
  end

end
