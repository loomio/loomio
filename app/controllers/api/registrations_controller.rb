class API::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  def create
    build_resource(sign_up_params)
    if resource.save
      LoginTokenService.create(actor: resource, uri: URI::parse(request.referrer.to_s))
      head :ok
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  def oauth
    resource = user_from_pending_identity.tap(&:save)
    if resource.persisted?
      sign_in resource
      flash[:notice] = t(:'devise.sessions.signed_up')
      head :ok
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.require(:recaptcha) if ENV['RECAPTCHA_APP_KEY'].present?
      u.permit(:name, :email, :recaptcha)
    end
  end

  def user_from_pending_identity
    User.new(name: pending_identity&.name, email: pending_identity&.email)
  end
end
