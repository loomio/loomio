# Recover pending channel rows if their initial enqueue was lost. Duplicate jobs
# are harmless because channel workers claim the delivery under a row lock.
class DispatchPendingNotificationDeliveriesWorker < ApplicationJob
  BATCH_SIZE = 500
  CLAIM_TIMEOUT = 15.minutes

  def perform
    release_stale_claims

    NotificationDelivery.available
                        .where(status: "pending", channel: %w[email chatbot])
                        .limit(BATCH_SIZE)
                        .pluck(:id, :channel)
                        .each do |delivery_id, channel|
      worker_for(channel).perform_later(delivery_id)
    end
  end

  private

  def release_stale_claims
    NotificationDelivery.where(
      status: "claimed",
      channel: %w[email chatbot],
      claimed_at: ..CLAIM_TIMEOUT.ago
    ).limit(BATCH_SIZE).update_all(
      status: "pending",
      claimed_at: nil,
      updated_at: Time.current
    )
  end

  def worker_for(channel)
    case channel
    when "email" then DeliverNotificationEmailWorker
    when "chatbot" then DeliverNotificationChatbotWorker
    end
  end
end
