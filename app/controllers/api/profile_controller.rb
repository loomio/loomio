class API::ProfileController < API::RestfulController

  def update_profile
    service.update user_params
    respond_with_resource
  end

  def upload_avatar
    service.update user: current_user, actor: current_user, params: { uploaded_avatar: params[:file], avatar_kind: :uploaded }
    respond_with_resource
  end

  def change_password
    service.change_password(user_params) { sign_in resource, bypass: true }
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
    { user: current_user, actor: current_user, params: permitted_params.user }
  end

  def resource_serializer
    CurrentUserSerializer
  end

  def serializer_root
    :users
  end

  def service
    UserService
  end
end
