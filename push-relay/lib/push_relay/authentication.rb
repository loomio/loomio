require_relative "crypto"
require_relative "error"

module PushRelay
  class Authentication
    def initialize(repository, clock: -> { Time.now.to_i })
      @repository, @clock = repository, clock
    end

    def verify!(registration, env, body)
      timestamp, nonce, signature = env.values_at("HTTP_X_LOOMIO_TIMESTAMP", "HTTP_X_LOOMIO_NONCE", "HTTP_X_LOOMIO_SIGNATURE")
      valid = timestamp.is_a?(String) && /\A\d{10}\z/.match?(timestamp) &&
        nonce.is_a?(String) && /\A[A-Za-z0-9_-]{22,86}\z/.match?(nonce)
      valid &&= (@clock.call - timestamp.to_i).abs <= 300
      if valid
        expected = Crypto.signature(method: env.fetch("REQUEST_METHOD"), path: env.fetch("PATH_INFO"),
          timestamp: timestamp, nonce: nonce, body: body, key: registration.fetch(:delivery_key))
        valid = Crypto.valid_signature?(signature, expected) &&
          @repository.claim_nonce(registration.fetch(:id), nonce.encode(Encoding::US_ASCII), timestamp.to_i + 600)
      end
      raise Error.new(401, "invalid_signature") unless valid
    end
  end
end
