class Api::V1::RegistrationsController < ApplicationController
  include LocalesHelper
  include RequiresLocalLogin
  skip_before_action :require_local_login, only: :complete
  before_action :permission_check, only: :create

  def create
    @registration_proof = registration_proof
    unless turnstile_ok?
      render json: { errors: { turnstile: [ :'auth_form.turnstile_required' ] } }, status: 403
      return
    end

    result = RegistrationService.create(email: registration_email, email_control_proved: @registration_proof.present?)
    user = result.user

    case result.status
    when :invalid
      render json: { errors: user.errors }, status: :unprocessable_entity
    when :incomplete
      save_detected_locale(user)
      preserve_selected_proof
      stage_account_completion(user)
      render json: {
        success: :ok,
        signed_in: false,
        incomplete: true,
        name: user.name,
        legal_acceptance_required: user.legal_acceptance_required?,
        email_newsletter: user.email_newsletter
      }
    when :sign_in
      save_detected_locale(user)
      preserve_selected_proof
      sign_in(user)
      flash[:notice] = t('auth_form.signed_in')
      render json: Boot::User.new(user, root_url: URI(root_url).origin, flash: flash).payload.merge(success: :ok, signed_in: true)
    when :send_code
      save_detected_locale(user) if user && !user.email_verified?
      LoginTokenService.create(actor: user, uri: referrer_uri)
      render json: { success: :ok, signed_in: false }
    end
  end

  def complete
    proof = pending_account_completion_proof
    return respond_with_error(401) unless proof

    user = proof.user
    authentication_method = pending_account_completion_authentication_method
    completion_params = account_completion_params
    completion_params = completion_params.except(:name) if proof.name_managed?

    # Lock the user before the proof, matching sign-in's update/revocation order.
    # Consuming the proof with the profile and session prevents concurrent or
    # restored-cookie replay while preserving retries after validation failure.
    User.transaction do
      user.lock!
      proof = AccountCompletionProof.lock.find_by(id: proof.id)
      return respond_with_error(401) unless proof && proof.expires_at.future? && user.active?

      user.require_valid_signup = true
      user.assign_attributes(completion_params)
      user.save!
      proof.destroy!
      sign_in(user, handle_pending: false)
    end

    session.delete(:pending_account_completion)
    handle_pending_actions(user)
    flash[:notice] = t('auth_form.signed_in')
    Sentry.metrics.count("auth.sign_in", attributes: { method: "account_completion" })
    render json: Boot::User.new(user, root_url: URI(root_url).origin, flash: flash).payload.merge(
      signed_in_via_login_code: authentication_method == "login_code",
      signed_in_via_password: authentication_method == "password",
      authentication_redirect: authentication_return_path
    ).compact
    EventBus.broadcast('session_create', user)
  rescue ActiveRecord::RecordInvalid
    render json: { errors: user.errors }, status: :unprocessable_entity
  end

  private
  # Select exactly one valid proof for the submitted email. Request invitation
  # tokens take precedence over old session state, and a mismatched proof does
  # not hide a matching proof of another kind.
  def registration_proof
    [ requested_invitation, pending_useable_login_token, pending_identity, pending_membership, pending_topic_reader, pending_stance ].compact.find do |record|
      record.user&.email&.casecmp?(registration_email)
    end
  end

  def requested_invitation
    [
      params[:membership_token] && Membership.pending.find_by(token: params[:membership_token]),
      params[:topic_reader_token] && TopicReader.redeemable.find_by(token: params[:topic_reader_token]),
      params[:stance_token] && Stance.find_by(token: params[:stance_token])
    ].compact.first
  end

  def referrer_uri
    URI.parse(request.referrer.to_s)
  rescue URI::InvalidURIError
    nil
  end

  def pending_useable_login_token
    pending_login_token if pending_login_token&.useable?
  end
  def permission_check
    if !(AppConfig.app_features[:create_user] || pending_invitation || pending_group)
      render json: { errors: { email: [ I18n.t('auth_form.invitation_required') ] } }, status: 422
    end
  end

  # Invitations prove control of the invited email address, but one user can
  # send many invitations, so every registration still needs abuse protection.
  def turnstile_ok?
    TurnstileService.verify(params.dig(:user, :turnstile_token) || params[:turnstile_token],
                            remote_ip: request.remote_ip)
  end

  def sign_up_params
    params.require(:user).permit(:email, :turnstile_token)
  end

  def registration_email
    @registration_email ||= sign_up_params[:email].to_s.strip.downcase
  end

  def account_completion_params
    params.require(:user).permit(:name, :legal_accepted, :email_newsletter)
  end

  def clear_pending_invitations
    session.delete(:pending_membership_token)
    session.delete(:pending_topic_reader_token)
    session.delete(:pending_stance_token)
  end

  def selected_invitation
    case @registration_proof
    when Membership, TopicReader, Stance
      @registration_proof
    end
  end

  def preserve_selected_proof
    session.delete(:pending_login_token) unless @registration_proof.is_a?(LoginToken)
    session.delete(:pending_identity_id) unless @registration_proof.is_a?(Identity)
    restore_pending_invitation(selected_invitation)
  end

  def restore_pending_invitation(invitation)
    clear_pending_invitations
    case invitation
    when Membership
      session[:pending_membership_token] = invitation.token
    when TopicReader
      session[:pending_topic_reader_token] = invitation.token
    when Stance
      session[:pending_stance_token] = invitation.token
    end
  end
end
