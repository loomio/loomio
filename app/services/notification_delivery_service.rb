# Create channel work at its database identity boundary. Enqueue only when this
# attempt inserted the delivery so producer retries cannot schedule the same
# notification, channel and recipient twice.
class NotificationDeliveryService
  INDEX_IDENTITY = "index_notification_deliveries_on_identity"

  def self.attributes_for(notification:, recipient:, channel:, translation_values: {})
    now = Time.current
    {
      notification_id: notification.id,
      recipient_type: recipient.class.base_class.name,
      recipient_id: recipient.id,
      channel: channel,
      translation_values: translation_values,
      status: "pending",
      available_at: now,
      created_at: now,
      updated_at: now
    }
  end
end
