class API::ProfileController < API::RestfulController

  def show
    load_and_authorize :user
    respond_with_resource serializer: UserSerializer
  end

  def me
    raise CanCan::AccessDenied.new unless current_user.is_logged_in?
    self.resource = current_user
    respond_with_resource serializer: UserSerializer
  end

  def remind
    service.remind(user: load_resource, actor: current_user, model: load_and_authorize(:poll))
    respond_with_resource
  end

  def update_profile
    service.update(current_user_params)
    respond_with_resource
  end

  def set_volume
    service.set_volume(user: current_user, actor: current_user, params: params.slice(:volume, :apply_to_all))
    respond_with_resource
  end

  def upload_avatar
    service.update user: current_user, actor: current_user, params: { uploaded_avatar: params[:file], avatar_kind: :uploaded }
    respond_with_resource
  end

  def deactivate
    service.deactivate(current_user_params)
    respond_with_resource
  end

  def save_experience
    raise ActionController::ParameterMissing.new(:experience) unless params[:experience]
    service.save_experience user: current_user, actor: current_user, params: { experience: params[:experience] }
    respond_with_resource
  end

  def email_status
    respond_with_resource(serializer: Pending::UserSerializer, scope: {has_token: has_invitation_token?})
  end

  private

  def resource
    @user || current_user.presence || user_by_email
  end

  def user_by_email
    resource_class.active.verified_first.find_by(email: params[:email]) || LoggedOutUser.new(email: params[:email])
  end

  def current_user_params
    { user: current_user, actor: current_user, params: permitted_params.user }
  end

  def has_invitation_token?
    return unless invitation = Invitation.find_by(token: params[:token])
    invitation.token if resource.email == invitation.email
  end

  def resource_class
    User
  end

  def resource_serializer
    if current_user.restricted
      Restricted::UserSerializer
    else
      Full::UserSerializer
    end
  end

  def serializer_root
    :users
  end

  def service
    UserService
  end
end
