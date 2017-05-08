class API::SessionsController < Devise::SessionsController
  def create
    if user = warden.authenticate(scope: resource_name)
      sign_in(resource_name, user)
      render json: BootData.new(user).data
    else
      render json: { errors: { password: [t(:"devise.failure.invalid")] } }, status: 401
    end
  end

  def destroy
    MessageChannelService.publish({ action: :logged_out }, to: current_user)
    sign_out resource_name
    flash[:notice] = t(:'devise.sessions.signed_out')
    head :ok
  end
end
