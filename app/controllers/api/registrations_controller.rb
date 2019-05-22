class API::RegistrationsController < Devise::RegistrationsController
  include LocalesHelper
  before_action :configure_permitted_parameters
  before_action :permission_check, only: :create

  def create
    @email_is_verified = email_is_verified?
    self.resource = find_user
    if UserService.create(user: resource, params: sign_up_params)
      save_detected_locale(resource)
      if @email_is_verified
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
  end

  private
  def find_user
    pending_user ||
    User.find_by(email: sign_up_params[:email], email_verified: false) ||
    build_resource
  end

  def email_is_verified?
    (pending_membership&.user  ||
     pending_login_token&.user ||
     pending_identity)&.email == sign_up_params[:email]
  end

  def pending_user
    (pending_membership || pending_login_token || pending_identity)&.user
  end

  def permission_check
    AppConfig.app_features[:create_user] || pending_membership
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:name, :email, :recaptcha, :legal_accepted)
    end
  end
end
