class DigestService
  # A digest acknowledgement covers exactly its notification and topic-item time
  # window. Both read-state changes commit together, then clients are refreshed.
  def self.mark_as_read(user_id:, time_start_i:, time_finish_i:)
    user = User.find_by!(id: user_id)
    time_start = Time.at(time_start_i).utc
    time_finish = Time.at(time_finish_i).utc
    notification_ids = []

    ApplicationRecord.transaction do
      TopicService.mark_digest_as_read(user.id, time_start_i, time_finish_i)

      deliveries = NotificationDelivery.delivered.joins(:notification).where(
        recipient: user,
        channel: "in_app",
        viewed_at: nil,
        notifications: { created_at: time_start..time_finish }
      )
      notification_ids = deliveries.distinct.pluck(:notification_id)
      deliveries.update_all(viewed_at: Time.current, updated_at: Time.current)
    end

    MessageChannelService.publish_models(
      Notification.where(id: notification_ids).includes(:actor),
      user_id: user.id
    ) if notification_ids.any?
  end
end
