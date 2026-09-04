require "test_helper"

class DeleteMobileRelayRegistrationWorkerTest < ActiveSupport::TestCase
  test "does not let a stale deletion job remove an active registration" do
    registration = create_registration

    Mobile::RelayService.stub(:delete!, ->(**) { flunk("active registration must not be deleted") }) do
      DeleteMobileRelayRegistrationWorker.perform_now(
        registration.id,
        registration.registration_id,
        registration.delivery_key_ciphertext
      )
    end

    assert MobilePushRegistration.exists?(registration.id)
  end

  test "deletes remotely after the local device record has been removed" do
    registration = create_registration
    registration_id = registration.registration_id
    delivery_key = registration.delivery_key
    delivery_key_ciphertext = registration.delivery_key_ciphertext
    local_id = registration.id
    registration.mobile_device.destroy!
    captured = nil

    Mobile::RelayService.stub(:delete!, ->(registration:) do
      captured = [ registration.registration_id, registration.delivery_key ]
      true
    end) do
      DeleteMobileRelayRegistrationWorker.perform_now(local_id, registration_id, delivery_key_ciphertext)
    end

    assert_equal [ registration_id, delivery_key ], captured
  end

  private

  def create_registration
    device = users(:member).mobile_devices.create!(
      name: "Cleanup iPhone",
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
