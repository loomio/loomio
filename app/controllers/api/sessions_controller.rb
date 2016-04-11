class API::SessionsController < Devise::SessionsController
  include DeviseControllerHelper

  def create
    if user = warden.authenticate
      sign_in resource_name, user
      render json: CurrentUserSerializer.new(user).as_json
    else
      render json: {error: 'wark' }, status: 401
    end
  end

  def destroy
    sign_out resource_name
    flash[:notice] = t(:'devise.sessions.signed_out')
    head :ok
  end
end
