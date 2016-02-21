class API::OauthApplicationsController < API::RestfulController

  def show
    load_and_authorize_resource
    respond_with_resource
  end

  def revoke_access
    load_and_authorize_resource
    service.revoke_access(oauth_application: resource, actor: current_user)
    respond_with_resource
  end

  private

  def load_and_authorize_resource
    load_and_authorize :oauth_application, const: resource_class
  end

  def resource_class
    Doorkeeper::Application
  end

  def accessible_records
    current_user.oauth_applications
  end

end
