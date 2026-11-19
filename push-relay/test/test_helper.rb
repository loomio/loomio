require "bundler/setup"
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "stringio"
require "securerandom"
require "rack/mock"
require "rack/lint"
require_relative "../lib/push_relay"
require_relative "../lib/push_relay/backup"

class RelayTest < Minitest::Test
  ID = "123e4567-e89b-42d3-a456-426614174000"
  EVENT_ID = "123e4567-e89b-42d3-a456-426614174001"
  DELIVERY_KEY = "b" * 43

  class Verifier
    attr_reader :calls
    attr_accessor :response, :error
    def initialize
      @calls = []
      @response = { "registration_id" => ID, "delivery_key" => DELIVERY_KEY }
    end
    def verify(origin, authorization)
      @calls << [origin, authorization]
      raise @error if @error
      @response
    end
  end

  class APNS
    attr_reader :calls
    attr_accessor :result, :error
    def initialize
      @calls, @result = [], :delivered
    end
    def send_notification!(registration, event)
      @calls << [registration, event]
      raise @error if @error
      @result
    end
  end

  def setup
    @directory = Dir.mktmpdir("loomio-relay-test-")
    @path = File.join(@directory, "relay.sqlite3")
    @database = PushRelay::Database.open(@path)
    PushRelay::Database.migrate(@database)
    @key, @time = SecureRandom.random_bytes(32), 1_700_000_000.0
    @repository = PushRelay::Repository.new(@database, @key, clock: -> { @time })
    @verifier, @apns, @log = Verifier.new, APNS.new, StringIO.new
    @app = build_app
  end

  def teardown
    @repository.close
    FileUtils.remove_entry(@directory)
  end

  def build_app(rate_limiter: PushRelay::RateLimiter.new(clock: -> { 0 }))
    PushRelay::App.new(repository: @repository, verifier: @verifier, apns: @apns,
      rate_limiter: rate_limiter, clock: -> { @time.to_i }, logger: @log)
  end

  def registration(id: ID, environment: "sandbox", token: "a" * 64)
    { id: id, host_origin: "https://community.example", apns_token: token,
      delivery_key: DELIVERY_KEY, environment: environment }
  end

  def register
    @repository.upsert_registration(**registration)
  end

  def registration_body(**changes)
    { host_origin: "https://community.example", authorization: "lm_ra_#{SecureRandom.urlsafe_base64(32, false)}",
      apns_token: "a" * 64, environment: "sandbox" }.merge(changes)
  end

  def request(method, path, body: "{}", headers: {}, app: @app)
    Rack::MockRequest.new(Rack::Lint.new(app)).request(method, path,
      { input: body, "CONTENT_TYPE" => "application/json", "REMOTE_ADDR" => "192.0.2.1" }.merge(headers))
  end

  def signed_request(method = "POST", path = "/v1/registrations/#{ID}/events", body: JSON.generate(event_id: EVENT_ID, kind: "notification"), nonce: SecureRandom.urlsafe_base64(24, false), timestamp: @time.to_i.to_s, headers: {}, app: @app, key: DELIVERY_KEY)
    signature = PushRelay::Crypto.signature(method: method, path: path, timestamp: timestamp, nonce: nonce, body: body, key: key)
    request(method, path, body: body, app: app, headers: {
      "HTTP_X_LOOMIO_TIMESTAMP" => timestamp, "HTTP_X_LOOMIO_NONCE" => nonce, "HTTP_X_LOOMIO_SIGNATURE" => signature
    }.merge(headers))
  end
end
