class Mobile::RelayAuthorizationService
  AUTHORIZATION_TTL = 60.seconds

  class << self
    def issue!(device:)
      endpoint = registration_endpoint
      raw = "lm_ra_#{SecureRandom.urlsafe_base64(32, false)}"

      MobileRelayAuthorization.transaction do
        device.lock!
        raise Mobile::AuthenticationService::Error.new("device_revoked", status: :unauthorized) unless device.active?

        device.mobile_relay_authorizations.where(consumed_at: nil).update_all(consumed_at: Time.current)
        registration = device.mobile_push_registration
        delivery_key = registration&.delivery_key || SecureRandom.urlsafe_base64(32, false)
        device.mobile_relay_authorizations.create!(
          token_digest: Mobile::AuthenticationService.digest(raw, :relay_authorization),
          registration_id: registration&.registration_id || SecureRandom.uuid,
          delivery_key_ciphertext: Mobile::RelayCredentialCipher.encrypt(delivery_key),
          expires_at: AUTHORIZATION_TTL.from_now
        )
      end

      {
        authorization: raw,
        expires_in: AUTHORIZATION_TTL.to_i,
        relay_registration_endpoint: endpoint
      }
    end

    def verify!(raw)
      MobileRelayAuthorization.transaction do
        authorization = MobileRelayAuthorization.includes(:mobile_device).lock.find_by(
          token_digest: Mobile::AuthenticationService.digest(raw, :relay_authorization)
        )
        raise Mobile::AuthenticationService::Error.new("invalid_grant", status: :unauthorized) unless authorization&.usable?

        authorization.update!(consumed_at: Time.current)
        device = authorization.mobile_device
        device.lock!
        registration = device.mobile_push_registration || device.build_mobile_push_registration
        registration.update!(
          registration_id: authorization.registration_id,
          delivery_key_ciphertext: authorization.delivery_key_ciphertext
        )
        {
          registration_id: registration.registration_id,
          delivery_key: Mobile::RelayCredentialCipher.decrypt(registration.delivery_key_ciphertext)
        }
      end
    end

    def registration_endpoint
      base = ENV["PUSH_RELAY_URL"].to_s.chomp("/")
      uri = URI.parse(base)
      unless uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil? &&
             [ "", "/" ].include?(uri.path) && uri.query.nil? && uri.fragment.nil?
        raise Mobile::AuthenticationService::Error.new("relay_unavailable", status: :service_unavailable)
      end
      "#{base}/v1/registrations"
    rescue URI::InvalidURIError
      raise Mobile::AuthenticationService::Error.new("relay_unavailable", status: :service_unavailable)
    end
  end
end
