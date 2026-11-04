module PasskeyService
  CHALLENGE_REGISTRATION = :passkey_registration_challenge
  CHALLENGE_AUTHENTICATION = :passkey_authentication_challenge
  CHALLENGE_TTL = 5.minutes
  RECENT_AUTHENTICATION_TTL = 10.minutes

  def self.relying_party(request_origin:, request_rp_id:)
    canonical_host = ENV["CANONICAL_HOST"].presence
    canonical_port = ENV["CANONICAL_PORT"].presence
    canonical_scheme = ENV.key?("FORCE_SSL") ? "https" : "http"
    origin = if canonical_host
      "#{canonical_scheme}://#{canonical_host}#{canonical_port ? ":#{canonical_port}" : ""}"
    else
      request_origin
    end

    WebAuthn::RelyingParty.new(
      allowed_origins: [origin],
      id: canonical_host || request_rp_id,
      name: AppConfig.theme[:site_name],
      verify_attestation_statement: false
    )
  end

  def self.recently_authenticated?(session_record)
    session_record&.created_at && session_record.created_at >= RECENT_AUTHENTICATION_TTL.ago
  end

  def self.ensure_webauthn_id!(user)
    return user.webauthn_id if user.webauthn_id.present?

    user.update!(webauthn_id: WebAuthn.generate_user_id)
    user.webauthn_id
  end

  # The cookie binds the ceremony to this browser, while the locked database
  # row makes consumption one-time even if an older encrypted cookie is replayed.
  def self.issue_challenge!(session, key, challenge, user: nil)
    discard_challenge!(session, key)
    PasskeyChallenge.where(expires_at: ...Time.current).delete_all
    record = PasskeyChallenge.create!(
      challenge_digest: challenge_digest(challenge),
      ceremony: key.to_s,
      user: user,
      expires_at: CHALLENGE_TTL.from_now
    )
    session[key] = { value: challenge, challenge_id: record.id }
  end

  def self.consume_challenge!(session, key, user: nil)
    challenge = session.delete(key)
    value = challenge && (challenge['value'] || challenge[:value])
    challenge_id = challenge && (challenge['challenge_id'] || challenge[:challenge_id])
    raise WebAuthn::Error, "missing or expired challenge" if value.blank? || challenge_id.blank?

    PasskeyChallenge.transaction do
      record = PasskeyChallenge.lock.find_by(
        id: challenge_id,
        challenge_digest: challenge_digest(value),
        ceremony: key.to_s,
        user_id: user&.id
      )
      raise WebAuthn::Error, "missing or expired challenge" unless record&.expires_at&.future?

      record.destroy!
    end

    value
  end

  def self.discard_challenge!(session, key)
    challenge = session.delete(key)
    challenge_id = challenge && (challenge['challenge_id'] || challenge[:challenge_id])
    PasskeyChallenge.where(id: challenge_id).delete_all if challenge_id
  end

  def self.challenge_digest(challenge)
    Digest::SHA256.hexdigest(challenge)
  end
  private_class_method :challenge_digest
end
