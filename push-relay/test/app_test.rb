require_relative "test_helper"

class AppTest < RelayTest
  def test_registers_only_after_host_verification
    response = request("POST", "/v1/registrations", body: JSON.generate(registration_body(host_origin: "https://Community.Example:443/")))
    assert_equal 201, response.status
    assert_equal({ "registration_id" => ID }, JSON.parse(response.body))
    assert_equal "https://community.example", @verifier.calls.first.first
    assert_equal registration, @repository.find_registration(ID)
  end

  def test_one_phone_can_receive_from_two_hosts_and_disconnect_them_independently
    first = request("POST", "/v1/registrations", body: JSON.generate(registration_body))
    second_id = SecureRandom.uuid
    second_key = "c" * 43
    @verifier.response = { "registration_id" => second_id, "delivery_key" => second_key }
    second = request("POST", "/v1/registrations", body: JSON.generate(registration_body(host_origin: "https://second.example")))
    assert_equal 201, first.status
    assert_equal 201, second.status
    assert_equal 202, signed_request.status
    assert_equal 202, signed_request("POST", "/v1/registrations/#{second_id}/events", key: second_key).status
    assert_equal 401, signed_request("DELETE", "/v1/registrations/#{second_id}", body: "{}").status
    assert_equal [ID, second_id], @apns.calls.map { |record, _event| record.fetch(:id) }
    assert_equal 200, signed_request("DELETE", "/v1/registrations/#{ID}", body: "{}").status
    assert_nil @repository.find_registration(ID)
    assert @repository.find_registration(second_id)
    assert_equal 202, signed_request("POST", "/v1/registrations/#{second_id}/events", body: JSON.generate(event_id: SecureRandom.uuid, kind: "notification"), key: second_key).status
  end

  def test_verified_host_cannot_overwrite_another_hosts_registration
    register
    response = request("POST", "/v1/registrations", body: JSON.generate(registration_body(host_origin: "https://second.example")))
    assert_equal 409, response.status
    assert_equal registration, @repository.find_registration(ID)
  end

  def test_invalid_or_failed_verification_never_creates_a_registration
    @verifier.response = { "registration_id" => ID, "delivery_key" => DELIVERY_KEY, "unexpected" => true }
    assert_equal 502, request("POST", "/v1/registrations", body: JSON.generate(registration_body)).status
    assert_nil @repository.find_registration(ID)
    @verifier.error = PushRelay::Error.new(502, "upstream_unavailable")
    assert_equal 502, request("POST", "/v1/registrations", body: JSON.generate(registration_body)).status
    assert_nil @repository.find_registration(ID)
  end

  def test_rejects_invalid_payloads_before_verifying_a_host
    [registration_body(authorization: "bad"), registration_body(apns_token: []), registration_body(environment: "other"),
      registration_body(host_origin: "http://example.com"), registration_body(actor_name: "private content"), [], nil].each do |body|
      assert_equal 400, request("POST", "/v1/registrations", body: JSON.generate(body)).status
    end
    assert_empty @verifier.calls
  end

  def test_rejects_bad_media_type_oversized_body_and_malformed_json
    assert_equal 415, request("POST", "/v1/registrations", headers: { "CONTENT_TYPE" => "text/plain" }).status
    assert_equal 413, request("POST", "/v1/registrations", body: "x" * 16_385).status
    assert_equal 400, request("POST", "/v1/registrations", body: "{").status
    assert_empty @verifier.calls
  end

  def test_delivers_signed_requests_and_rejects_replays
    register
    nonce = SecureRandom.urlsafe_base64(24, false)
    assert_equal 202, signed_request(nonce: nonce).status
    assert_equal 401, signed_request(nonce: nonce).status
    duplicate = signed_request
    assert_equal 202, duplicate.status
    assert_equal true, JSON.parse(duplicate.body).fetch("duplicate")
    assert_equal 1, @apns.calls.size
    row = @database.get_first_row("SELECT * FROM relay_events")
    assert_equal @time, row.fetch("delivered_at")
    assert_nil row.fetch("failed_at")
  end

  def test_rejects_changed_body_expired_timestamp_and_bad_signatures
    register
    assert_equal 401, signed_request(timestamp: (@time.to_i - 301).to_s).status
    assert_equal 401, signed_request(timestamp: (@time.to_i + 301).to_s).status
    assert_equal 401, signed_request(headers: { "HTTP_X_LOOMIO_SIGNATURE" => "bad" }).status
    assert_equal 401, request("POST", "/v1/registrations/#{ID}/events").status
    path = "/v1/registrations/#{ID}/events"
    body = JSON.generate(event_id: EVENT_ID, kind: "notification")
    nonce = SecureRandom.urlsafe_base64(24, false)
    signature = PushRelay::Crypto.signature(method: "POST", path: path, timestamp: @time.to_i.to_s, nonce: nonce, body: body, key: DELIVERY_KEY)
    assert_equal 401, signed_request(body: body + " ", nonce: nonce, headers: { "HTTP_X_LOOMIO_SIGNATURE" => signature }).status
    assert_empty @apns.calls
  end

  def test_rejects_query_variations_bad_ids_and_wrong_methods
    register
    assert_equal 404, signed_request("POST", "/v1/registrations/#{ID}/events?extra=1").status
    assert_equal 404, request("POST", "/v1/registrations/not-a-uuid/events").status
    assert_equal 405, request("GET", "/v1/registrations/#{ID}/events").status
    assert_equal 405, request("PUT", "/v1/registrations").status
    assert_equal 404, request("POST", "/unknown").status
    assert_empty @apns.calls
  end

  def test_signed_deletion_cascades_nonce_and_delivery_history
    register
    signed_request
    response = signed_request("DELETE", "/v1/registrations/#{ID}", body: "{}")
    assert_equal 200, response.status
    assert_nil @repository.find_registration(ID)
    %w[relay_nonces relay_events].each { |table| assert_equal 0, @database.get_first_value("SELECT count(*) FROM #{table}") }
    assert_equal 404, signed_request.status
  end

  def test_unsigned_or_nonempty_deletion_cannot_remove_a_device
    register
    assert_equal 401, request("DELETE", "/v1/registrations/#{ID}").status
    assert_equal 405, signed_request("DELETE", "/v1/registrations/#{ID}", body: '{"extra":true}').status
    assert @repository.find_registration(ID)
  end

  def test_transient_apns_failure_can_be_retried_with_same_event_id
    register
    @apns.error = PushRelay::APNSClient::DeliveryError.new("InvalidProviderToken")
    response = signed_request
    assert_equal 503, response.status
    assert_equal "30", response["retry-after"]
    assert @repository.find_registration(ID)
    @apns.error = nil
    assert_equal 202, signed_request.status
    assert_equal 2, @apns.calls.size
    assert_equal 2, @database.get_first_value("SELECT attempts FROM relay_events")
  end

  def test_permanent_apns_failure_removes_registration
    register
    @apns.result = :permanent
    assert_equal 410, signed_request.status
    assert_nil @repository.find_registration(ID)
    assert_equal 404, signed_request.status
  end

  def test_rejects_host_controlled_notification_content_and_invalid_badges
    register
    [{ event_id: EVENT_ID, kind: "notification", body: "secret" },
      { event_id: EVENT_ID, kind: "other" }, { event_id: EVENT_ID, kind: "notification", badge: -1 },
      { event_id: EVENT_ID, kind: "notification", badge: 100_000 }, { event_id: EVENT_ID, kind: "notification", badge: 1.5 }].each do |event|
      assert_equal 405, signed_request(body: JSON.generate(event)).status
    end
    assert_empty @apns.calls
    assert_equal 202, signed_request(body: JSON.generate(event_id: EVENT_ID, kind: "test", badge: 3)).status
  end

  def test_rate_limits_before_parsing_or_storage_and_keeps_health_available
    limiter = PushRelay::RateLimiter.new(clock: -> { 0 })
    app = build_app(rate_limiter: limiter)
    11.times do |i|
      assert_equal 201, request("POST", "/v1/registrations", body: JSON.generate(registration_body),
        headers: { "HTTP_X_FORWARDED_FOR" => "192.0.2.#{i}" }, app: app).status
    end
    response = request("POST", "/v1/registrations", body: "bad-json", app: app)
    assert_equal 429, response.status
    assert_equal "2", response["retry-after"]
    assert_equal 11, @verifier.calls.size
    assert_equal 200, request("GET", "/health", app: app).status
    assert_equal "no-store", response["cache-control"]
  end

  def test_signed_routes_share_limits_even_for_failed_authentication
    register
    51.times { assert_equal 401, request("POST", "/v1/registrations/#{ID}/events").status }
    response = signed_request("DELETE", "/v1/registrations/#{ID}")
    assert_equal 429, response.status
    assert_equal "1", response["retry-after"]
    assert @repository.find_registration(ID)
  end

  def test_generic_errors_do_not_log_credentials_or_private_content
    @verifier.error = RuntimeError.new("private-device-token")
    response = request("POST", "/v1/registrations", body: JSON.generate(registration_body))
    assert_equal 502, response.status
    refute_includes response.body, "private-device-token"
    refute_includes @log.string, "private-device-token"
    refute_includes @log.string, "lm_ra_"
  end
end
