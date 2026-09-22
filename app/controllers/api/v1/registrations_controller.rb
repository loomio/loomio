class Api::V1::RegistrationsController < ApplicationController
  include LocalesHelper
  include RequiresLocalLogin
  skip_before_action :require_local_login, only: :complete
  before_action :permission_check, only: :create
  attr_accessor :resource

  def create
    @email_can_be_verified = email_can_be_verified?
    unless turnstile_ok?
      render json: { errors: { turnstile: [:'auth_form.turnstile_required'] } }, status: 403
      return
    end
    self.resource = UserService.create(params: sign_up_params)
    if !resource.errors.any?
      save_detected_locale(resource)
      if @email_can_be_verified
        if resource.account_completion_required?
          preserve_pending_invitation
          stage_account_completion(resource)
          render json: {
            success: :ok,
            signed_in: false,
            account_completion_required: true,
            name: resource.name,
            email_newsletter: resource.email_newsletter
          }
        else
          sign_in resource
          flash[:notice] = t('auth_form.signed_in')
          render json: Boot::User.new(resource, root_url: URI(root_url).origin, flash: flash).payload.merge({ success: :ok, signed_in: true })
        end
      else
        LoginTokenService.create(actor: resource, uri: referrer_uri)
        render json: { success: :ok, signed_in: false }
      end
      EventBus.broadcast('registration_create', resource)
    else
      render json: { errors: resource.errors }, status: 422
    end
  rescue UserService::EmailTakenError
    user = User.active.find_by(email: sign_up_params[:email])
    LoginTokenService.create(actor: user, uri: referrer_uri) if user
    render json: { success: :ok, signed_in: false }
  end

  def complete
    proof = pending_account_completion_proof
    return respond_with_error(401) unless proof

    user = proof.user
    completion_params = account_completion_params
    completion_params = completion_params.except(:name) if proof.name_managed?

    # Lock the user before the proof, matching sign-in's update/revocation order.
    # Consuming the proof with the profile and session prevents concurrent or
    # restored-cookie replay while preserving retries after validation failure.
    User.transaction do
      user.lock!
      proof = AccountCompletionProof.lock.find_by(id: proof.id)
      return respond_with_error(401) unless proof && proof.expires_at.future? && user.active_for_authentication?

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
      signed_in_via_login_code: true,
      authentication_redirect: authentication_return_path
    ).compact
    EventBus.broadcast('session_create', user)
  rescue ActiveRecord::RecordInvalid
    render json: { errors: user.errors }, status: :unprocessable_entity
  end

  private
  def email_can_be_verified?
    (pending_membership&.user  ||
     pending_useable_login_token&.user ||
     pending_topic_reader&.user ||
     pending_stance&.user ||
     pending_identity)&.email == sign_up_params[:email]
  end

  def pending_user
    user = (pending_membership || pending_useable_login_token || pending_identity)&.user
    user if user && !user.email_verified?
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
      render json: { errors: {email: [I18n.t('auth_form.invitation_required')], name: [I18n.t('auth_form.invitation_required')]}}, status: 422
    end
  end

  # Users following a pending_membership / login_token / identity flow have
  # proved control of their email by clicking an emailed link, so they skip
  # the challenge — same bypass as the sessions controller's pending_login_token path.
  def turnstile_ok?
    return true if @email_can_be_verified
    TurnstileService.verify(params.dig(:user, :turnstile_token) || params[:turnstile_token],
                            remote_ip: request.remote_ip)
  end

  def sign_up_params
    params.require(:user).permit(:email, :turnstile_token)
  end

  def account_completion_params
    params.require(:user).permit(:name, :legal_accepted, :email_newsletter)
  end

  def preserve_pending_invitation
    session[:pending_membership_token] ||= params[:membership_token]
    session[:pending_topic_reader_token] ||= params[:topic_reader_token]
    session[:pending_stance_token] ||= params[:stance_token]
  end
end
