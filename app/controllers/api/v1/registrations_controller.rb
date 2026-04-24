class Api::V1::RegistrationsController < Devise::RegistrationsController
  include LocalesHelper
  before_action :configure_permitted_parameters
  before_action :permission_check, only: :create

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
        sign_in resource
        flash[:notice] = t(:'devise.sessions.signed_in')
        render json: Boot::User.new(resource, root_url: URI(root_url).origin).payload.merge({ success: :ok, signed_in: true })
      else
        LoginTokenService.create(actor: resource, uri: URI.parse(request.referrer.to_s))
        render json: { success: :ok, signed_in: false }
      end
      EventBus.broadcast('registration_create', resource)
    else
      render json: { errors: resource.errors }, status: 422
    end
  rescue UserService::EmailTakenError => e
    render json: { errors: { email: [ I18n.t('auth_form.email_taken') ] } }, status: 422
  end

  private
  def email_can_be_verified?
    (pending_membership&.user  ||
     pending_login_token&.user ||
     pending_topic_reader&.user ||
     pending_stance&.user ||
     pending_identity)&.email == sign_up_params[:email]
  end

  def pending_user
    user = (pending_membership || pending_login_token || pending_identity)&.user
    user if user && !user.email_verified?
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

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:name, :email, :legal_accepted, :email_newsletter, :turnstile_token)
    end
  end
end
