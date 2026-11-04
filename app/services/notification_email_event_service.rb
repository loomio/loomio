# Repeated feedback reports can describe the same failure. Serialize updates
# per delivery so both reports are retained but suppression is applied only once.
# Only an explicit recipient address from feedback may create an address block.
class NotificationEmailEventService
  def self.record!(delivery:, kind:, source_key:, occurred_at:, detail: nil, bounce_type: nil, recipient_address: nil)
    raise 'Email feedback requires a user email delivery' unless delivery.channel == 'email' && delivery.recipient_type == 'User'

    User.transaction do
      # Account redaction locks the user before clearing delivery snapshots. Use
      # the same lock order and never restore feedback containing erased data.
      user = User.lock.find_by(id: delivery.recipient_id)
      return unless user&.email
      delivery.with_lock do
        return if delivery.email_message_id.blank? && delivery.provider_message_id.blank?
        return if delivery.events.exists?(source_key: source_key)

        event = delivery.events.create!(kind: kind, source_key: source_key, occurred_at: occurred_at,
          detail: detail, bounce_type: bounce_type)
        reason = EmailSuppressionService.reason_for(kind: kind, bounce_type: bounce_type)
        if reason && recipient_address.present?
          EmailSuppressionService.record!(email: recipient_address, reason: reason,
            source_key: "delivery:#{delivery.id}:#{reason}", event: event, occurred_at: occurred_at)
        end
        event
      end
    end
  end
end
