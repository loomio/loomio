# Delivery routing is safe to enqueue from inside the notification transaction
# and safe to retry after a partial worker failure.
class RouteNotificationDeliveriesWorker < ApplicationJob
  self.enqueue_after_transaction_commit = true

  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_id)
    notification = Notification.find_by(id: notification_id)
    return unless notification

    NotificationDeliveryRouter.for(notification).route!
  end
end
