require "test_helper"

class Mobile::RelayServiceTest < ActiveSupport::TestCase
  setup do
    @relay_url = ENV["PUSH_RELAY_URL"]
    ENV["PUSH_RELAY_URL"] = "https://push.example.test"
  end

  teardown do
    @relay_url.nil? ? ENV.delete("PUSH_RELAY_URL") : ENV["PUSH_RELAY_URL"] = @relay_url
  end

  test "derives a stable UUID-shaped event id from a notification delivery" do
    first = Mobile::RelayService.event_id_for(123)

    assert_equal first, Mobile::RelayService.event_id_for(123)
    refute_equal first, Mobile::RelayService.event_id_for(124)
    assert_match(/\A[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/, first)
  end

  test "native delivery uses the relay and marks the delivery delivered" do
    user = users(:member)
    user.update!(deactivated_at: nil)
    device = user.mobile_devices.create!(
      name: "Worker iPhone",
      platform: "ios",
      protocol_version: 1,
      last_seen_at: Time.current
    )
    registration = device.create_mobile_push_registration!(
      registration_id: SecureRandom.uuid,
      delivery_key_ciphertext: Mobile::RelayCredentialCipher.encrypt(SecureRandom.urlsafe_base64(32, false))
    )
    notification = Notification.create!(
      kind: "discussion_edited",
      subject: discussions(:discussion),
      actor: users(:user),
      recipient_user_ids: [ user.id ]
    )
    delivery = NotificationDelivery.create!(
      notification: notification,
      recipient: registration,
      channel: "push"
    )
    captured = nil

    Mobile::RelayService.stub(:deliver!, ->(**args) { captured = args; true }) do
      DeliverNotificationPushWorker.perform_now(delivery.id)
    end

    assert_equal registration, captured[:registration]
    assert_equal "notification", captured[:kind]
    assert_equal Mobile::RelayService.event_id_for(delivery.id), captured[:event_id]
    assert delivery.reload.delivered_at
  end

  test "signs the exact generic relay payload without notification content" do
    registration = create_registration
    event_id = SecureRandom.uuid
    captured = nil
    stub_request(:post, "https://push.example.test/v1/registrations/#{registration.registration_id}/events")
      .with do |request|
        captured = request
        canonical = [
          "POST",
          request.uri.path,
          request.headers.fetch("X-Loomio-Timestamp"),
          request.headers.fetch("X-Loomio-Nonce"),
          Digest::SHA256.hexdigest(request.body)
        ].join("\n")
        expected = Base64.urlsafe_encode64(
          OpenSSL::HMAC.digest("SHA256", registration.delivery_key, canonical),
          padding: false
        )
        request.headers.fetch("X-Loomio-Signature") == expected
      end
      .to_return(status: 202, body: '{"accepted":true}', headers: { "Content-Type" => "application/json" })

    assert Mobile::RelayService.deliver!(registration: registration, event_id: event_id, kind: "notification")
    assert_equal({ "event_id" => event_id, "kind" => "notification" }, JSON.parse(captured.body))
  end

  test "removes a stale host registration when the relay no longer has it" do
    registration = create_registration
    stub_request(:post, "https://push.example.test/v1/registrations/#{registration.registration_id}/events")
      .to_return(status: 404, body: '{"error":"not_found"}', headers: { "Content-Type" => "application/json" })

    refute Mobile::RelayService.deliver!(
      registration: registration,
      event_id: SecureRandom.uuid,
      kind: "notification"
    )
    refute MobilePushRegistration.exists?(registration.id)
  end

  private

  def create_registration
    user = users(:member)
    user.update!(deactivated_at: nil)
    device = user.mobile_devices.create!(
      name: "Signed iPhone",
      platform: "ios",
      protocol_version: 1,
      last_seen_at: Time.current
    )
    device.create_mobile_push_registration!(
      registration_id: SecureRandom.uuid,
      delivery_key_ciphertext: Mobile::RelayCredentialCipher.encrypt(SecureRandom.urlsafe_base64(32, false))
    )
  end
end
