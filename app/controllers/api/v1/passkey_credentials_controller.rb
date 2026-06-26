class Api::V1::PasskeyCredentialsController < Api::V1::RestfulController
  before_action :require_current_user, only: [:registration_options, :create]

  def registration_options
    options = relying_party.options_for_registration(
      user: {
        id: PasskeyService.ensure_webauthn_id!(current_user),
        name: current_user.email,
        display_name: current_user.name.presence || current_user.email
      },
      exclude: current_user.passkey_credentials.pluck(:external_id),
      authenticator_selection: { user_verification: "preferred" }
    )

    session[PasskeyService::CHALLENGE_REGISTRATION] = options.challenge
    render json: options
  end

  def create
    credential = relying_party.verify_registration(
      credential_params,
      session.delete(PasskeyService::CHALLENGE_REGISTRATION)
    )

    current_user.passkey_credentials.create!(
      external_id: credential.id,
      public_key: credential.public_key,
      sign_count: credential.sign_count,
      nickname: params[:nickname],
      transports: Array(public_key_credential_params.dig("response", "transports"))
    )

    self.resource = current_user
    respond_with_resource
  rescue WebAuthn::Error, ActiveRecord::RecordInvalid, ArgumentError => e
    render json: { errors: { passkey: [e.message] } }, status: :unprocessable_entity
  end

  def authentication_options
    unless ThrottleService.can?(key: "PasskeyAuthenticationOptions", id: params[:email].to_s.downcase, max: 20, per: "hour")
      render json: { error: "Rate limit exceeded" }, status: :too_many_requests
      return
    end

    user = User.active.find_by(email: params[:email])
    credentials = user&.passkey_credentials || PasskeyCredential.none

    if user.nil? || credentials.empty?
      render json: { errors: { email: [I18n.t("auth_form.email_not_found")] } }, status: :not_found
      return
    end

    options = relying_party.options_for_authentication(
      allow: credentials.pluck(:external_id),
      user_verification: "preferred"
    )

    session[PasskeyService::CHALLENGE_AUTHENTICATION] = options.challenge
    session[PasskeyService::AUTHENTICATION_USER_ID] = user.id
    render json: options
  end

  def authenticate
    user = User.active.find_by(id: session.delete(PasskeyService::AUTHENTICATION_USER_ID))

    webauthn_credential, stored_credential = relying_party.verify_authentication(
      credential_params,
      session.delete(PasskeyService::CHALLENGE_AUTHENTICATION)
    ) do |webauthn_credential|
      user&.passkey_credentials&.find_by(external_id: webauthn_credential.id)
    end

    if stored_credential.nil?
      render json: { errors: { passkey: [I18n.t("auth_form.invalid_password")] } }, status: :unauthorized
      return
    end

    stored_credential.update!(
      sign_count: webauthn_credential.sign_count,
      last_used_at: Time.current
    )

    sign_in(user)
    flash[:notice] = t("auth_form.signed_in")
    render json: Boot::User.new(user, root_url: URI(root_url).origin, flash: flash).payload.merge(
      signed_in_via_login_code: false
    )
    EventBus.broadcast("session_create", user)
  rescue WebAuthn::Error, NoMethodError, ArgumentError
    render json: { errors: { passkey: [I18n.t("auth_form.invalid_password")] } }, status: :unauthorized
  end

  private

  def relying_party
    PasskeyService.relying_party(origin: request.base_url, rp_id: request.host)
  end

  def credential_params
    public_key_credential_params.to_h
  end

  def public_key_credential_params
    credential = params[:public_key_credential] || params[:publicKeyCredential]
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
        :signature,
        :userHandle,
        { transports: [] }
      ]
    )
  end
end
