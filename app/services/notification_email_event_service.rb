# Email feedback and API polling can report the same failure. Serialize updates
# per delivery so both reports are retained but suppression is applied only once.
class NotificationEmailEventService
  def self.record!(delivery:, kind:, source_key:, occurred_at:, detail: nil)
    raise 'Email feedback requires a user email delivery' unless delivery.channel == 'email' && delivery.recipient_type == 'User'

    User.transaction do
      # Account redaction locks the user before clearing delivery snapshots. Use
      # the same lock order and never restore feedback containing erased data.
      user = User.lock.find_by(id: delivery.recipient_id)
      return unless user&.email
      delivery.with_lock do
        return if delivery.email_address.blank? || delivery.events.exists?(source_key: source_key)

        did_record_kind = delivery.events.exists?(kind: kind)
        event = delivery.events.create!(kind: kind, source_key: source_key, occurred_at: occurred_at, detail: detail)
        if !did_record_kind && %w[bounced complained].include?(kind)
          column = kind == 'bounced' ? 'bounces_count' : 'complaints_count'
          User.where(id: user.id, email: delivery.email_address).update_all("#{column} = #{column} + 1")
        end
        event
      end
    end
  end
end
