class API::OauthApplicationsController < API::RestfulController
  load_resource only: [:revoke_access, :upload_logo]

  def show
    load_and_authorize :oauth_application
    respond_with_resource
  end

  def owned
    instantiate_collection { |collection| collection.where(owner: current_user) }
    respond_with_collection
  end

  def authorized
    instantiate_collection { OauthApplication.authorized_for(current_user) }
    respond_with_collection
  end

  def revoke_access
    load_resource
    service.revoke_access(oauth_application: resource, actor: current_user)
    respond_with_resource
  end

  def upload_logo
    service.update oauth_application: resource, actor: current_user, params: { logo: params[:file] }
    respond_with_resource
  end

  private

  def accessible_records
    OauthApplication.all
  end

  def default_scope
    { user_id: current_user.id }
  end

end
