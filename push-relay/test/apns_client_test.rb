require_relative "test_helper"

class APNSClientTest < Minitest::Test
  def setup
    @production = OpenSSL::PKey::EC.generate("prime256v1")
    @sandbox = OpenSSL::PKey::EC.generate("prime256v1")
    @config = { team_id: "ABCDE12345", topic: "org.loomio.mobile",
      production: { key_id: "PRODKEY123", private_key: @production }, sandbox: { key_id: "SANDKEY123", private_key: @sandbox } }
    @time = 1_700_000_000
    @requests, @response = [], [200, ""]
    @client = PushRelay::APNSClient.new(@config, clock: -> { @time }, transport: ->(*request) { @requests << request; @response })
    @registration = { id: SecureRandom.uuid, apns_token: "a" * 64, environment: "sandbox" }
    @event = { "event_id" => SecureRandom.uuid, "kind" => "notification" }
  end

  def test_signs_and_caches_separate_environment_tokens
    [["production", @production, "PRODKEY123"], ["sandbox", @sandbox, "SANDKEY123"]].each do |environment, key, key_id|
      token = @client.provider_token(environment)
      payload, header = JWT.decode(token, OpenSSL::PKey.read(key.public_to_pem), true, algorithm: "ES256")
      assert_equal key_id, header.fetch("kid")
      assert_equal @time, payload.fetch("iat")
      assert_equal "ABCDE12345", payload.fetch("iss")
      assert_equal token, @client.provider_token(environment)
    end
    old = @client.provider_token("production")
    @time += 3_000
    refute_equal old, @client.provider_token("production")
  end

  def test_legacy_shared_signing_key_support
    @config[:sandbox] = nil
    token = @client.provider_token("sandbox")
    _, header = JWT.decode(token, @production, true, algorithm: "ES256")
    assert_equal "PRODKEY123", header.fetch("kid")
  end

  def test_sends_generic_payload_to_correct_environment
    assert_equal :delivered, @client.send_notification!(@registration, @event)
    url, headers, body = @requests.first
    assert_equal "https://api.sandbox.push.apple.com/3/device/#{'a' * 64}", url
    assert_equal "org.loomio.mobile", headers.fetch("apns-topic")
    assert_equal @event.fetch("event_id"), headers.fetch("apns-id")
    assert_equal "alert", headers.fetch("apns-push-type")
    value = JSON.parse(body)
    assert_equal %w[aps event_id registration_id], value.keys.sort
    assert_equal "New Loomio activity", value.fetch("aps").fetch("alert").fetch("title")
    @registration[:environment] = "production"
    @client.send_notification!(@registration, @event.merge("kind" => "test", "badge" => 3))
    assert @requests.last.first.start_with?("https://api.push.apple.com/")
    assert_equal 3, JSON.parse(@requests.last.last).fetch("aps").fetch("badge")
  end

  def test_only_device_specific_failures_are_permanent
    [[400, "BadDeviceToken"], [400, "DeviceTokenNotForTopic"], [410, "Unregistered"]].each do |status, reason|
      @response = [status, JSON.generate(reason: reason)]
      assert_equal :permanent, @client.send_notification!(@registration, @event)
    end
    [[403, "InvalidProviderToken"], [403, "ExpiredProviderToken"], [429, "TooManyRequests"], [500, "InternalServerError"]].each do |status, reason|
      @response = [status, JSON.generate(reason: reason)]
      assert_raises(PushRelay::APNSClient::DeliveryError) { @client.send_notification!(@registration, @event) }
    end
  end
end
