# Serialize block/clear operations per address, including reports with no user or
# delivery match. Replayed evidence must never reinstate a block that was cleared.
class EmailSuppressionService
  def self.reason_for(kind:, bounce_type: nil)
    return 'complaint' if kind == 'complained'
    'permanent_bounce' if kind == 'bounced' && bounce_type == 'Permanent'
  end

  def self.record!(email:, reason:, source_key:, event: nil, occurred_at: nil)
    return if email.blank?

    digest = EmailSuppression.address_digest(email)
    EmailSuppression.transaction do
      lock_address(digest)
      EmailSuppression.find_or_create_by!(source_key: source_key) do |record|
        record.assign_attributes(email_sha256: digest, reason: reason,
          notification_delivery_event: event, occurred_at: occurred_at)
      end
    end
  end

  def self.clear!(user:, actor:, method:)
    raise ArgumentError, 'Unknown clearance method' unless %w[sign_in administrator].include?(method)

    user.with_lock do
      return if user.email.blank?

      lock_address(EmailSuppression.address_digest(user.email))
      EmailSuppression.for_address(user.email).active.update_all(cleared_at: Time.current,
        cleared_by_id: actor.id, clear_method: method, updated_at: Time.current)
    end
  end

  def self.lock_address(digest)
    connection = EmailSuppression.connection
    connection.execute("SELECT pg_advisory_xact_lock(hashtextextended(#{connection.quote(digest)}, 0))")
  end
  private_class_method :lock_address
end
