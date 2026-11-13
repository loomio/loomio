require "rack"
require "json"
require "sqlite3"
require_relative "registrations"
require_relative "authentication"
require_relative "deliveries"
require_relative "rate_limiter"

module PushRelay
  class App
    def initialize(repository:, verifier:, apns:, rate_limiter: RateLimiter.new, clock: -> { Time.now.to_i }, logger: $stderr)
      @repository, @rate_limiter, @logger = repository, rate_limiter, logger
      @registrations = Registrations.new(repository: repository, verifier: verifier)
      @authentication = Authentication.new(repository, clock: clock)
      @deliveries = Deliveries.new(repository: repository, apns: apns)
    end

    def call(env)
      request = Rack::Request.new(env)
      path = request.path_info.encode(Encoding::UTF_8)
      return json(200, status: "ok", protocol_version: 1) if request.get? && path == "/health"
      raise Error.new(404, "not_found") unless request.query_string.empty?
      registration_route = path == "/v1/registrations"
      match = path.match(%r{\A/v1/registrations/([0-9a-f-]+)(/events)?\z}i)
      signed_route = match && Validation::UUID.match?(match[1])
      raise Error.new(404, "not_found") unless registration_route || signed_route
      method = registration_route || match[2] ? "POST" : "DELETE"
      raise Error.new(405, "method_not_allowed") unless request.request_method == method
      retry_after = @rate_limiter.retry_after(env, registration_route ? :registrations : :deliveries)
      raise Error.new(429, "rate_limited", retry_after: retry_after) if retry_after
      raise Error.new(415, "unsupported_media_type") unless request.media_type == "application/json"
      raw = env.fetch("rack.input").read(16_385).to_s
      raise Error.new(413, "upstream_unavailable") if raw.bytesize > 16_384
      value = raw.empty? ? {} : JSON.parse(raw)
      return json(201, registration_id: @registrations.create!(value).fetch(:id)) if registration_route

      registration = @repository.find_registration(match[1])
      raise Error.new(404, "not_found") unless registration
      @authentication.verify!(registration, env, raw)
      return json(202, @deliveries.deliver!(registration, value)) if match[2]
      raise Error.new(405, "method_not_allowed") unless Validation.exact_keys?(value, [])
      @repository.delete_registration(registration.fetch(:id))
      json(200, deleted: true)
    rescue Error => error
      headers = error.retry_after ? { "retry-after" => error.retry_after.to_s } : {}
      json(error.status, { error: error.code }, headers)
    rescue JSON::ParserError, EncodingError
      json(400, error: "invalid_request")
    rescue SQLite3::Exception
      failure(env, 503, "temporarily_unavailable", { "retry-after" => "30" })
    rescue StandardError
      failure(env, 502, "upstream_unavailable")
    end

    private

    def failure(env, status, code, headers = {})
      # Never log request bodies, credentials, or upstream exception messages.
      @logger.puts(JSON.generate(event: "relay_request_failed", method: env["REQUEST_METHOD"], status: status, code: code))
      json(status, { error: code }, headers)
    end

    def json(status, payload, headers = {})
      body = JSON.generate(payload)
      [status, { "content-type" => "application/json", "cache-control" => "no-store", "content-length" => body.bytesize.to_s }.merge(headers), [body]]
    end
  end
end
