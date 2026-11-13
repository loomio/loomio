require "httpx"
require "jwt"
require "json"
require "securerandom"

module PushRelay
  class APNSClient
    class DeliveryError < StandardError
      attr_reader :reason
      def initialize(reason = "apns_unavailable")
        @reason = reason
        super("APNs delivery failed")
      end
    end

    PERMANENT_REASONS = %w[BadDeviceToken DeviceTokenNotForTopic Unregistered].freeze

    def initialize(config, clock: -> { Time.now.to_i }, transport: nil)
      @config, @clock = config, clock
      @transport = transport || method(:request)
      @tokens, @mutex = {}, Mutex.new
    end

    def provider_token(environment)
      @mutex.synchronize do
        now = @clock.call
        cached = @tokens[environment]
        return cached[:token] if cached && (now - cached[:created_at]).between?(0, 2_999)
        key = environment == "sandbox" ? (@config[:sandbox] || @config.fetch(:production)) : @config.fetch(:production)
        token = JWT.encode({ iss: @config.fetch(:team_id), iat: now }, key.fetch(:private_key), "ES256", kid: key.fetch(:key_id))
        @tokens[environment] = { token: token, created_at: now }
        token
      end
    end

    def self.payload(registration_id:, event_id:, kind:, badge: nil)
      alert = if kind == "test"
        { title: "Loomio notifications are working", body: "This device is ready for Loomio updates." }
      else
        { title: "New Loomio activity", body: "Open Loomio to view it." }
      end
      aps = { alert: alert, sound: "default" }
      aps[:badge] = badge if badge.is_a?(Integer) && badge >= 0
      JSON.generate(aps: aps, registration_id: registration_id, event_id: event_id)
    end

    def send_notification!(registration, event)
      environment = registration.fetch(:environment)
      authority = environment == "production" ? "https://api.push.apple.com" : "https://api.sandbox.push.apple.com"
      payload = self.class.payload(registration_id: registration.fetch(:id), event_id: event.fetch("event_id"),
        kind: event.fetch("kind"), badge: event["badge"])
      headers = { "authorization" => "bearer #{provider_token(environment)}", "apns-topic" => @config.fetch(:topic),
        "apns-push-type" => "alert", "apns-priority" => "10", "apns-id" => event.fetch("event_id"), "content-type" => "application/json" }
      status, body = @transport.call("#{authority}/3/device/#{registration.fetch(:apns_token)}", headers, payload)
      return :delivered if status == 200
      reason = begin
        parsed = JSON.parse(body)
        parsed.is_a?(Hash) ? parsed["reason"] : nil
      rescue JSON::ParserError
        nil
      end
      return :permanent if status == 410 || PERMANENT_REASONS.include?(reason)
      raise DeliveryError.new(reason.is_a?(String) ? reason.slice(0, 128) : "apns_unavailable")
    end

    private

    def request(url, headers, body)
      # Each request owns its session, so Puma threads never share mutable HTTP/2 state.
      client = HTTPX.with(ssl: { alpn_protocols: ["h2"] }, fallback_protocol: "h2",
        timeout: { connect_timeout: 5, operation_timeout: 10, request_timeout: 10 })
      response = client.post(url, headers: headers, body: body)
      raise DeliveryError if response.is_a?(HTTPX::ErrorResponse)
      [response.status, response.to_s]
    rescue HTTPX::Error, IOError, SystemCallError, OpenSSL::SSL::SSLError
      raise DeliveryError
    ensure
      client&.close
    end
  end
end
