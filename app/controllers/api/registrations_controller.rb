class API::RegistrationsController < Devise::RegistrationsController
  include LocalesHelper
  before_action :configure_permitted_parameters
  before_action :permission_check, only: :create

  def create
    @email_can_be_verified = email_can_be_verified?
    self.resource = UserService.create(params: sign_up_params)
    if resource.valid?
      save_detected_locale(resource)
      if @email_can_be_verified
        sign_in resource
        flash[:notice] = t(:'devise.sessions.signed_in')
        render json: Boot::User.new(resource).payload.merge({ success: :ok, signed_in: true })
      else
        LoginTokenService.create(actor: resource, uri: URI::parse(request.referrer.to_s))
        render json: { success: :ok, signed_in: false }
      end
    else
      render json: { errors: resource.errors }, status: 422
    end
  rescue UserService::EmailTakenError => e
    render json: {errors: {email: [I18n.t('auth_form.email_taken')]}}, status: 422
  end

  private
  def email_can_be_verified?
    (pending_membership&.user  ||
     pending_login_token&.user ||
     pending_discussion_reader&.user ||
     pending_stance&.user ||
     pending_identity)&.email == sign_up_params[:email]
  end

  def pending_user
    user = (pending_membership || pending_login_token || pending_identity)&.user
    user if user && !user.email_verified?
  end

  def permission_check
    if !(AppConfig.app_features[:create_user] || pending_membership)
      render json: { errors: I18n.t('auth_form.invitation_required')}, status: 422
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:name, :email, :recaptcha, :legal_accepted, :email_newsletter)
    end
  end
end
