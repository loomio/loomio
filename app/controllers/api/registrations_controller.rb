class API::RegistrationsController < Devise::RegistrationsController
  include LocalesHelper
  before_action :configure_permitted_parameters
  before_action :permission_check, only: :create

  def create
    build_resource(sign_up_params)
    if resource.save
      save_detected_locale(resource)
      if invitation_is_present?
        sign_in resource
        flash[:notice] = t(:'devise.sessions.signed_in')
      else
        LoginTokenService.create(actor: resource, uri: URI::parse(request.referrer.to_s))
      end
      render json: { success: :ok }
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  def oauth
    resource = user_from_pending_identity.tap(&:save)
    if resource.persisted?
      sign_in resource
      flash[:notice] = t(:'devise.sessions.signed_up')
      render json: { success: :ok }
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  private
  def permission_check
    AppConfig.app_features[:create_user] || pending_invitation
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.require(:recaptcha) if !invitation_is_present? && ENV['RECAPTCHA_APP_KEY']
      u.permit(:name, :email, :recaptcha)
    end
  end

  def user_from_pending_identity
    User.new(name: pending_identity&.name, email: pending_identity&.email)
  end

  def invitation_is_present?
    pending_invitation.present? &&
    pending_invitation.single_use? &&
    pending_invitation.email == params[:user][:email]
  end
end
