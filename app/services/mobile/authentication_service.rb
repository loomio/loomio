require "base64"
require "openssl"

class Mobile::AuthenticationService
  PROTOCOL_VERSION = 1
  CLIENT_ID = "org.loomio.mobile.ios"
  REDIRECT_URI = "org.loomio.mobile:/oauth/callback"
  SCOPES = "activity:read activity:write notifications:manage relay:register web_session:create device:revoke"

  AUTHORIZATION_CODE_TTL = 2.minutes
  ACCESS_TOKEN_TTL = 15.minutes
  REFRESH_IDLE_TTL = 90.days
  REFRESH_ABSOLUTE_TTL = 1.year
  WEB_SESSION_TICKET_TTL = 60.seconds

  class Error < StandardError
    attr_reader :code, :status

    def initialize(code, status: :bad_request)
      @code = code
      @status = status
      super(code)
    end
  end

  class << self
    def issue_authorization_code!(user:, code_challenge:)
      raw = random_token("lm_ac_")
      MobileAuthorizationCode.create!(
        user: user,
        token_digest: digest(raw, :authorization_code),
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        code_challenge: code_challenge,
        expires_at: AUTHORIZATION_CODE_TTL.from_now
      )
      raw
    end

    def exchange_authorization_code!(code:, code_verifier:, client_id:, redirect_uri:, device_name:)
      validate_public_client!(client_id: client_id, redirect_uri: redirect_uri)
      validate_code_verifier!(code_verifier)

      MobileAuthorizationCode.transaction do
        authorization = MobileAuthorizationCode.lock.find_by(token_digest: digest(code, :authorization_code))
        invalid_grant! unless authorization&.usable?
        invalid_grant! unless authorization.client_id == client_id && authorization.redirect_uri == redirect_uri
        invalid_grant! unless secure_match?(authorization.code_challenge, pkce_challenge(code_verifier))

        authorization.update!(used_at: Time.current)
        device = MobileDevice.create!(
          user: authorization.user,
          name: normalized_device_name(device_name),
          platform: "ios",
          protocol_version: PROTOCOL_VERSION,
          last_seen_at: Time.current
        )
        issue_token_pair!(device: device)
      end
    end

    def refresh!(refresh_token:, client_id:)
      raise Error.new("invalid_client", status: :unauthorized) unless client_id == CLIENT_ID

      reused = false
      pair = MobileRefreshToken.transaction do
        token = MobileRefreshToken.lock.find_by(token_digest: digest(refresh_token, :refresh_token))
        invalid_grant! unless token

        if token.consumed_at.present?
          token.mobile_device.revoke!
          reused = true
          next
        end

        invalid_grant! unless token.usable?

        token.update!(consumed_at: Time.current)
        issue_token_pair!(device: token.mobile_device, parent: token, absolute_expires_at: token.expires_at)
      end

      if reused
        Sentry.metrics.count("mobile_auth.refresh_reuse")
        invalid_grant!
      end

      pair
    end

    def authenticate_access_token(raw_token)
      raise Error.new("invalid_token", status: :unauthorized) unless raw_token.to_s.start_with?("lm_at_")

      token = MobileAccessToken.includes(mobile_device: :user).find_by(token_digest: digest(raw_token, :access_token))
      raise Error.new("invalid_token", status: :unauthorized) unless token&.usable?

      token.mobile_device.update_column(:last_seen_at, Time.current)
      token
    end

    def issue_web_session_ticket!(device:)
      raw = random_token("lm_ws_")
      MobileWebSessionTicket.transaction do
        device.lock!
        raise Error.new("device_revoked", status: :unauthorized) unless device.active?
        device.mobile_web_session_tickets.where(consumed_at: nil).update_all(consumed_at: Time.current)
        device.mobile_web_session_tickets.create!(
          token_digest: digest(raw, :web_session_ticket),
          expires_at: WEB_SESSION_TICKET_TTL.from_now
        )
      end
      raw
    end

    def consume_web_session_ticket!(raw_ticket)
      MobileWebSessionTicket.transaction do
        ticket = MobileWebSessionTicket.includes(mobile_device: :user).lock.find_by(
          token_digest: digest(raw_ticket, :web_session_ticket)
        )
        raise Error.new("invalid_grant") unless ticket&.usable?

        ticket.update!(consumed_at: Time.current)
        ticket.mobile_device.user
      end
    end

    def token_response(pair)
      {
        token_type: "Bearer",
        access_token: pair.fetch(:access_token),
        expires_in: ACCESS_TOKEN_TTL.to_i,
        refresh_token: pair.fetch(:refresh_token),
        refresh_token_expires_in: [ REFRESH_IDLE_TTL.to_i, pair.fetch(:refresh_expires_at).to_i - Time.current.to_i ].min,
        device: {
          id: pair.fetch(:device).id,
          name: pair.fetch(:device).name
        },
        scope: SCOPES
      }
    end

    def digest(raw, purpose)
      OpenSSL::HMAC.hexdigest("SHA256", digest_key, "#{purpose}\0#{raw}")
    end

    private

    def issue_token_pair!(device:, parent: nil, absolute_expires_at: REFRESH_ABSOLUTE_TTL.from_now)
      access_raw = random_token("lm_at_")
      refresh_raw = random_token("lm_rt_")
      now = Time.current

      device.mobile_access_tokens.create!(
        token_digest: digest(access_raw, :access_token),
        scopes: SCOPES,
        expires_at: now + ACCESS_TOKEN_TTL
      )
      device.mobile_refresh_tokens.create!(
        parent: parent,
        token_digest: digest(refresh_raw, :refresh_token),
        family_id: device.refresh_family_id,
        expires_at: absolute_expires_at,
        idle_expires_at: [ now + REFRESH_IDLE_TTL, absolute_expires_at ].min
      )
      device.update!(last_seen_at: now)

      {
        access_token: access_raw,
        refresh_token: refresh_raw,
        refresh_expires_at: absolute_expires_at,
        device: device
      }
    end

    def validate_public_client!(client_id:, redirect_uri:)
      raise Error.new("invalid_client", status: :unauthorized) unless client_id == CLIENT_ID
      invalid_grant! unless redirect_uri == REDIRECT_URI
    end

    def validate_code_verifier!(verifier)
      valid = verifier.to_s.length.between?(43, 128) && verifier.match?(/\A[A-Za-z0-9\-._~]+\z/)
      raise Error.new("invalid_request") unless valid
    end

    def pkce_challenge(verifier)
      Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    end

    def normalized_device_name(name)
      name.to_s.strip.presence&.first(100) || "iPhone"
    end

    def random_token(prefix)
      "#{prefix}#{SecureRandom.urlsafe_base64(32, false)}"
    end

    def digest_key
      @digest_key ||= OpenSSL::HMAC.digest(
        "SHA256",
        Rails.application.secret_key_base,
        "loomio-mobile-credential-digest-v1"
      )
    end

    def secure_match?(left, right)
      left.bytesize == right.bytesize && ActiveSupport::SecurityUtils.secure_compare(left, right)
    end

    def invalid_grant!
      raise Error.new("invalid_grant", status: :unauthorized)
    end
  end
end
