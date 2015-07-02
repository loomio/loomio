class API::UsersController < API::RestfulController

  def update_profile
    service.update user_params
    respond_with_resource
  end

  def change_password
    service.change_password user_params
    respond_with_resource
  end

  def deactivate
    service.deactivate user_params
    respond_with_resource
  end

  private

  def resource
    current_user
  end

  def user_params
    { user: current_user, actor: current_user, params: resource_params }
  end

  def resource_serializer
    CurrentUserSerializer
  end
end
