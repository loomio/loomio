class API::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  def create
    build_resource(sign_up_params)
    if resource.save
      LoginTokenService.create(actor: resource)
      head :ok
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.require(:recaptcha)
      u.permit(:name, :email, :recaptcha)
    end
  end
end
