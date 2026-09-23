class Api::V1::PasskeyCredentialsController < Api::V1::RestfulController
  include RequiresLocalLogin
  before_action :require_current_user, only: [:index, :registration_options, :create, :destroy]
  before_action :forbid_restricted_user, only: [:index, :registration_options, :create, :destroy]
  before_action :require_recent_authentication, only: [:registration_options, :create, :destroy]

  def index
    render json: {
      passkey_credentials: current_user.passkey_credentials.order(created_at: :asc).map do |credential|
        {
          id: credential.id,
          name: credential.name,
          created_at: credential.created_at,
          last_used_at: credential.last_used_at
        }
      end
    }
  end

  def registration_options
    options = relying_party.options_for_registration(
      user: {
        id: PasskeyService.ensure_webauthn_id!(current_user),
        name: current_user.email,
        display_name: current_user.name.presence || current_user.email
      },
      exclude: current_user.passkey_credentials.pluck(:external_id),
      authenticator_selection: {
        resident_key: "required",
        user_verification: "required"
      }
    )

    PasskeyService.issue_challenge!(session, PasskeyService::CHALLENGE_REGISTRATION, options.challenge, user: current_user)
    render json: options
  end

  def create
    challenge = PasskeyService.consume_challenge!(session, PasskeyService::CHALLENGE_REGISTRATION, user: current_user)

    credential = relying_party.verify_registration(
      credential_params,
      challenge,
      user_verification: true
    )
    passkey = current_user.passkey_credentials.create!(
      external_id: credential.id,
      public_key: credential.public_key,
      sign_count: credential.sign_count,
      user_handle: current_user.webauthn_id,
      name: params[:name].presence || I18n.t('auth_form.passkey_default_name'),
      transports: Array(public_key_credential_params.dig("response", "transports"))
    )

    render json: { passkey_credential: { id: passkey.id, name: passkey.name } }, status: :created
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid, ArgumentError => error
    Rails.logger.warn("Passkey registration failed: #{error.class}: #{error.message}")
    render json: { errors: { passkey: [I18n.t('auth_form.passkey_registration_failed')] } }, status: :unprocessable_entity
  end

  def destroy
    current_user.passkey_credentials.find(params[:id]).destroy!
    render json: { success: true }
  end

  # Discoverable credentials deliberately omit an allow list. The authenticator
  # chooses an account locally and returns an opaque credential ID only after
  # user verification, so this endpoint does not accept or disclose an email.
  def authentication_options
    options = relying_party.options_for_authentication(user_verification: "required")
    PasskeyService.issue_challenge!(session, PasskeyService::CHALLENGE_AUTHENTICATION, options.challenge)
    render json: options
  end

  def authenticate
    challenge = PasskeyService.consume_challenge!(session, PasskeyService::CHALLENGE_AUTHENTICATION)

    webauthn_credential = nil
    stored_credential = nil
    PasskeyCredential.transaction do
      webauthn_credential, stored_credential = relying_party.verify_authentication(
        credential_params,
        challenge,
        user_verification: true
      ) do |credential|
        PasskeyCredential.lock.includes(:user).find_by!(external_id: credential.id)
      end

      user = stored_credential&.user
      raise WebAuthn::Error, "inactive credential owner" unless user&.active?
      raise WebAuthn::Error, "credential owner mismatch" unless webauthn_credential.user_handle == stored_credential.user_handle

      stored_credential.update!(
        sign_count: webauthn_credential.sign_count,
        last_used_at: Time.current
      )
    end

    user = stored_credential&.user
    sign_in(user)
    flash[:notice] = t('auth_form.signed_in')
    Sentry.metrics.count("auth.sign_in", attributes: { method: "passkey" })
    render json: Boot::User.new(user, root_url: URI(root_url).origin, flash: flash).payload.merge(
      signed_in_via_login_code: false,
      authentication_redirect: authentication_return_path
    ).compact
    EventBus.broadcast('session_create', user)
  rescue WebAuthn::Error, ActiveRecord::RecordNotFound, OpenSSL::PKey::PKeyError, ArgumentError
    Sentry.metrics.count("auth.sign_in_failed", attributes: { reason: "invalid_passkey" })
    render json: { errors: { passkey: [I18n.t('auth_form.passkey_authentication_failed')] } }, status: :unauthorized
  end

  private

  def forbid_restricted_user
    respond_with_error(403) if current_user.restricted
  end

  def relying_party
    PasskeyService.relying_party(request_origin: request.base_url, request_rp_id: request.host)
  end

  def require_recent_authentication
    return if PasskeyService.recently_authenticated?(Current.session)

    render json: { errors: { passkey: [I18n.t('auth_form.passkey_recent_authentication_required')] } }, status: :forbidden
  end

  def credential_params
    public_key_credential_params.to_h
  end

  def public_key_credential_params
    credential = params[:public_key_credential] || params[:publicKeyCredential]
    raise ActionController::ParameterMissing, :public_key_credential unless credential.respond_to?(:to_unsafe_h)

    ActionController::Parameters.new(credential.to_unsafe_h).permit(
      :id,
      :rawId,
      :type,
      :authenticatorAttachment,
      :clientExtensionResults,
      clientExtensionResults: {},
      response: [
        :attestationObject,
        :authenticatorData,
        :clientDataJSON,
        :publicKey,
        :publicKeyAlgorithm,
        :signature,
        :userHandle,
        { transports: [] }
      ]
    )
  end
end
