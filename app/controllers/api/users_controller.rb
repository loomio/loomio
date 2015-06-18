class API::UsersController < API::RestfulController

  def update_profile
    service.update(user: current_user, actor: current_user, params: resource_params)
    respond_with_current_user      
  end

  private

  def respond_with_current_user
    if current_user.errors.empty?
      render json: [current_user], each_serializer: CurrentUserSerializer, root: :users
    else
      respond_with_errors
    end
  end
end
