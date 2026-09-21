module PasskeyService
  CHALLENGE_REGISTRATION = :passkey_registration_challenge
  CHALLENGE_AUTHENTICATION = :passkey_authentication_challenge
  CHALLENGE_TTL = 5.minutes

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

  def self.issue_challenge!(session, key, challenge)
    session[key] = { value: challenge, issued_at: Time.current.to_i }
  end

  def self.consume_challenge!(session, key)
    challenge = session.delete(key)
    value = challenge && (challenge['value'] || challenge[:value])
    issued_at = challenge && (challenge['issued_at'] || challenge[:issued_at])
    raise WebAuthn::Error, "missing or expired challenge" if value.blank? || issued_at.blank?
    raise WebAuthn::Error, "missing or expired challenge" if Time.at(issued_at.to_i) < CHALLENGE_TTL.ago

    value
  end
end
