module NotificationDeliveryResolvers
  class UserMentioned < NotificationDeliveryResolver
    def self.deduplication_key(subject, occurrence_key: nil)
      if occurrence_key.blank?
        raise ArgumentError, "user_mentioned occurrence_key is required"
      end

      "user_mentioned:#{subject.class.base_class.name}_#{subject.id}:#{occurrence_key}"
    end

    private

    def recipients_by_channel
      recipients = explicit_users.active.verified
      {
        "in_app" => recipients.to_a,
        "email" => recipients.where(email_when_mentioned: true).no_spam_complaints.to_a
      }
    end
  end
end
