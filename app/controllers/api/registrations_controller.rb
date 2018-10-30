class API::RegistrationsController < Devise::RegistrationsController
  include LocalesHelper
  before_action :configure_permitted_parameters
  before_action :permission_check, only: :create

  def create
    build_resource(sign_up_params)
    if UserSerivce.create(resource)
      save_detected_locale(resource)
      if email_is_verified?
        sign_in resource
        flash[:notice] = t(:'devise.sessions.signed_in')
        render json: { success: :ok, signed_in: true }
      else
        LoginTokenService.create(actor: resource, uri: URI::parse(request.referrer.to_s))
        render json: { success: :ok }
      end
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  private
  def permission_check
    AppConfig.app_features[:create_user] || pending_membership
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:name, :email, :recaptcha, :legal_accepted)
    end
  end

  def email_is_verified?
    (pending_identity.present? && pending_identity.email == params[:user][:email]) or
    (pending_membership.present? && pending_membership.user.email == params[:user][:email])
  end
end
