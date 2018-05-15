class API::RegistrationsController < Devise::RegistrationsController
  include LocalesHelper
  before_action :configure_permitted_parameters
  before_action :permission_check, only: :create

  def create
    build_resource(sign_up_params)
    if resource.save
      save_detected_locale(resource)
      if pending_membership_is_present? or pending_identity_is_present?
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
      u.require(:recaptcha) if !pending_membership_is_present? && ENV['RECAPTCHA_APP_KEY']
      u.permit(:name, :email, :recaptcha, :legal_accepted)
    end
  end

  def user_from_pending_identity
    User.new(name: pending_identity&.name, email: pending_identity&.email)
  end

  def pending_identity_is_present?
    pending_identity.present? &&
    pending_identity.email == params[:user][:email]
  end

  def pending_membership_is_present?
    pending_membership.present? &&
    pending_membership.user.email == params[:user][:email]
  end
end
