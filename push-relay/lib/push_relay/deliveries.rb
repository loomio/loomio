require_relative "apns_client"
require_relative "registrations"

module PushRelay
  class Deliveries
    def initialize(repository:, apns:)
      @repository, @apns = repository, apns
    end

    def deliver!(registration, event)
      keys = %w[event_id kind]
      unless (Validation.exact_keys?(event, keys) || Validation.exact_keys?(event, keys + ["badge"])) &&
          Validation.matches?(event["event_id"], Validation::UUID) && %w[notification test].include?(event["kind"]) &&
          (!event.key?("badge") || (event["badge"].is_a?(Integer) && event["badge"].between?(0, 99_999)))
        raise Error.new(405, "method_not_allowed")
      end
      id, event_id = registration.fetch(:id), event.fetch("event_id")
      return { accepted: true, duplicate: true } unless @repository.claim_event(id, event_id)
      begin
        # The atomic event claim is committed before waiting on Apple's network.
        if @apns.send_notification!(registration, event) == :permanent
          @repository.delete_registration(id)
          raise Error.new(410, "registration_gone")
        end
        @repository.finish_event(id, event_id, delivered: true)
      rescue APNSClient::DeliveryError => error
        @repository.finish_event(id, event_id, delivered: false, error: error.reason)
        raise Error.new(503, "temporarily_unavailable", retry_after: 30)
      end
      { accepted: true }
    end
  end
end
