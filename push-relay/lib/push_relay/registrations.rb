require_relative "host_verifier"
require_relative "error"

module PushRelay
  module Validation
    UUID = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i
    module_function

    def exact_keys?(value, keys)
      value.is_a?(Hash) && value.keys.sort == keys.sort
    end

    def matches?(value, pattern)
      value.is_a?(String) && pattern.match?(value)
    end
  end

  class Registrations
    def initialize(repository:, verifier:)
      @repository, @verifier = repository, verifier
    end

    def create!(value)
      unless Validation.exact_keys?(value, %w[host_origin authorization apns_token environment]) &&
          Validation.matches?(value["authorization"], /\Alm_ra_[A-Za-z0-9_-]{43}\z/) &&
          Validation.matches?(value["apns_token"], /\A[0-9a-f]{64,200}\z/i) &&
          %w[sandbox production].include?(value["environment"])
        raise Error.new(400, "invalid_request")
      end
      origin = HostVerifier.normalized_origin(value.fetch("host_origin"))
      verified = @verifier.verify(origin, value.fetch("authorization"))
      unless Validation.exact_keys?(verified, %w[registration_id delivery_key]) &&
          Validation.matches?(verified["registration_id"], Validation::UUID) &&
          Validation.matches?(verified["delivery_key"], /\A[A-Za-z0-9_-]{43}\z/)
        raise Error.new(502, "upstream_unavailable")
      end
      @repository.upsert_registration(id: verified.fetch("registration_id"), host_origin: origin,
        apns_token: value.fetch("apns_token").downcase, delivery_key: verified.fetch("delivery_key"), environment: value.fetch("environment"))
    end
  end
end
