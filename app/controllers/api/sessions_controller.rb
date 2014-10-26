class API::SessionsController < API::BaseController
  include OmniauthAuthenticationHelper

  respond_to :json
  
  def create
    resource = User.find_by_email params[:email]
    if resource.try :valid_password?, params[:password]
      sign_in "User", resource
      head :ok
    else
      warden.custom_failure!
      head :unauthorized
    end
  end
  
  def destroy
    sign_out(resource_name)
  end

end
