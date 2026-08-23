module NotificationDeliveryResolvers
  class OutcomeUpdated < OutcomeChange
    def self.deduplication_key(outcome, occurrence_key: nil)
      raise ArgumentError, "outcome_updated occurrence_key is required" if occurrence_key.blank?

      "outcome_updated:outcome_#{outcome.id}:#{occurrence_key}"
    end
  end
end
