require "json"
require "openssl"

module Subscriptions
  class WebhookVerifier
    class InvalidSignature < StandardError; end

    AGE_MAX = 5.minutes

    def initialize(request, secret: ENV["LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET"])
      @request = request
      @secret = secret
    end

    def verify!
      raise InvalidSignature if @secret.blank?

      timestamp = Integer(@request.headers["X-Loomio-Subscriptions-Timestamp"])
      raise InvalidSignature if (Time.current.to_i - timestamp).abs > AGE_MAX.to_i

      supplied = @request.headers["X-Loomio-Subscriptions-Signature"].to_s
      expected = "sha256=#{OpenSSL::HMAC.hexdigest("SHA256", @secret, "#{timestamp}.#{@request.raw_post}")}"
      raise InvalidSignature unless supplied.bytesize == expected.bytesize &&
        ActiveSupport::SecurityUtils.secure_compare(supplied, expected)

      payload = JSON.parse(@request.raw_post)
      event_id = @request.headers["X-Loomio-Subscriptions-Event-Id"].to_s
      raise InvalidSignature unless event_id.present? && payload["event_id"] == event_id

      payload
    rescue ArgumentError, JSON::ParserError
      raise InvalidSignature
    end
  end
end
