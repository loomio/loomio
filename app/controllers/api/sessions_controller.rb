class API::SessionsController < Devise::SessionsController
  include DeviseControllerHelper

  def create
    if user = warden.authenticate(scope: resource_name)
      sign_in resource_name, user
      flash[:notice] = t(:'devise.sessions.signed_in')
      render json: BootData.new(user).data
    else
      render json: { errors: { password: [t(:"devise.failure.invalid")] } }, status: 401
    end
  end

  def destroy
    logged_out_user = current_user
    sign_out resource_name
    flash[:notice] = t(:'devise.sessions.signed_out')
    MessageChannelService.publish({ action: :logged_out }, to: logged_out_user)
    head :ok
  end
end
