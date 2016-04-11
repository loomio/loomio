class API::SessionsController < Devise::SessionsController
  include DeviseControllerHelper

  def create
    sign_in resource_name, resource
    render json: CurrentUserSerializer.new(current_user).as_json
  end

  def destroy
    sign_out resource_name
    flash[:notice] = t(:'devise.sessions.signed_out')
    head :ok
  end

  def unauthorized
    head :unauthorized
  end

  private

  def resource
    warden.authenticate! recall: "#{controller_path}#unauthorized"
  end
end
