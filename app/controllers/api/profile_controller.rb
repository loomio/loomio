class API::ProfileController < API::RestfulController

  def show
    load_and_authorize :user
    respond_with_resource serializer: UserSerializer
  end

  def update_profile
    service.update(current_user_params)
    respond_with_resource
  end

  def upload_avatar
    service.update user: current_user, actor: current_user, params: { uploaded_avatar: params[:file], avatar_kind: :uploaded }
    respond_with_resource
  end

  def change_password
    service.change_password(current_user_params) { sign_in resource, bypass: true }
    respond_with_resource
  end

  def deactivate
    service.deactivate(current_user_params)
    respond_with_resource
  end

  private

  def resource
    @user || current_user
  end

  def current_user_params
    { user: current_user, actor: current_user, params: permitted_params.user }
  end

  def resource_class
    User
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
