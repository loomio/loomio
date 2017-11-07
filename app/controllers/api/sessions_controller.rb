class API::SessionsController < Devise::SessionsController
  before_filter :configure_permitted_parameters

  def create
    if user = attempt_login
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
      render json: BootData.new(user).data
    else
      render json: { errors: { password: [t(:"devise.failure.invalid")] } }, status: 401
    end
    session.delete(:pending_token)
  end

  def destroy
    MessageChannelService.publish({ action: :logged_out }, to: current_user)
    sign_out resource_name
    flash[:notice] = t(:'devise.sessions.signed_out')
    head :ok
  end

  private

  def attempt_login
    if pending_token&.useable?
      pending_token.user
    else
      warden.authenticate(scope: resource_name)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
  end

end
