class API::RegistrationsController < Devise::RegistrationsController
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

  def sign_up_params
    params.require(:user).permit(:name, :email, :recaptcha).tap { |p| p.require(:recaptcha) }
  end
end
