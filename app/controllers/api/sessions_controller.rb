class API::SessionsController < Devise::SessionsController

  def create
    authenticate
    head :ok
  end

  def destroy
    authenticate && sign_out
    head :ok
  end

  def current
    render json: current_user, serializer: UserSerializer
  end

  def unauthorized
    head :unauthorized
  end

  private

  def authenticate
    warden.authenticate! scope: resource_name
  end
end
