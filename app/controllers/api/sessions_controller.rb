class API::SessionsController < Devise::SessionsController

  def create
    sign_in resource_name, resource
    head :ok
  end

  def destroy
    sign_out resource_name
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
