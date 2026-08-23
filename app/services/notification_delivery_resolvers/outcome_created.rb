module NotificationDeliveryResolvers
  class OutcomeCreated < OutcomeChange
    def self.deduplication_key(outcome, occurrence_key: nil)
      raise ArgumentError, "outcome_created occurrence_key is required" if occurrence_key.blank?

      "outcome_created:outcome_#{outcome.id}:#{occurrence_key}"
    end
  end
end
