module PasskeyService
  CHALLENGE_REGISTRATION = :passkey_registration_challenge
  CHALLENGE_AUTHENTICATION = :passkey_authentication_challenge
  AUTHENTICATION_USER_ID = :passkey_authentication_user_id

  def self.relying_party(origin:, rp_id:)
    WebAuthn::RelyingParty.new(
      allowed_origins: [origin],
      id: rp_id,
      name: AppConfig.theme[:site_name],
      verify_attestation_statement: false
    )
  end

  def self.ensure_webauthn_id!(user)
    return user.webauthn_id if user.webauthn_id.present?

    user.update!(webauthn_id: WebAuthn.generate_user_id)
    user.webauthn_id
  end
end
