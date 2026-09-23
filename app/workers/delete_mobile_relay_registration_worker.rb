class DeleteMobileRelayRegistrationWorker < ApplicationJob
  retry_on Mobile::RelayService::Error, wait: :polynomially_longer, attempts: 8

  RelayCredential = Data.define(:registration_id, :delivery_key_ciphertext) do
    def delivery_key
      Mobile::RelayCredentialCipher.decrypt(delivery_key_ciphertext)
    end
  end

  # Retain an encrypted credential in the job so redaction can remove the
  # device row immediately without preventing remote relay cleanup.
  def perform(mobile_push_registration_id, registration_id, delivery_key_ciphertext)
    registration = MobilePushRegistration.find_by(id: mobile_push_registration_id)
    return if registration&.mobile_device&.active?

    credential = registration || RelayCredential.new(
      registration_id: registration_id,
      delivery_key_ciphertext: delivery_key_ciphertext
    )

    registration&.destroy! if Mobile::RelayService.delete!(registration: credential)
  end
end
