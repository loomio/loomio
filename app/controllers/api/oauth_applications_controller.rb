class API::OauthApplicationsController < API::RestfulController

  def show
    load_and_authorize :oauth_application, const: resource_class
    respond_with_resource
  end

  def revoke_access
    load_resource
    service.revoke_access(oauth_application: resource, actor: current_user)
    respond_with_resource
  end

  private

  def resource_class
    Doorkeeper::Application
  end

  def accessible_records
    current_user.oauth_applications
  end

  def default_scope
    { user_id: current_user.id }
  end

end
