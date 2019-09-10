class API::ProfileController < API::RestfulController
  def show
    load_and_authorize :user
    respond_with_resource serializer: UserSerializer
  end

  def groups
    ids = current_user.formal_groups.pluck(:id)
    self.collection = Group.published.where('parent_id in (:ids) or id in (:ids)', ids: ids).
                            where('is_visible_to_parent_members = true or is_visible_to_public = true')
    respond_with_collection serializer: GroupSerializer, root: :groups
  end

  def time_zones
    time_zones = User.where('time_zone is not null').joins(:memberships).
                      where('memberships.group_id': current_user.formal_group_ids).
                      group(:time_zone).count.sort_by {|k,v| -v }
    render json: time_zones, root: false
  end

  def mentionable_users
    instantiate_collection do |collection|
      collection.mention_search(current_user, model, params[:q])
    end
    respond_with_collection serializer: Simple::UserSerializer, root: :users
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

  def destroy
    service.delay.destroy(user: current_user)
    respond_with_resource
  end

  def reactivate
    service.reactivate(user:deactivated_user, actor: current_user)
    respond_with_resource
  end

  def save_experience
    raise ActionController::ParameterMissing.new(:experience) unless params[:experience]
    service.save_experience user: current_user, actor: current_user, params: { experience: params[:experience] }
    respond_with_resource
  end

  def email_status
    respond_with_resource(serializer: Pending::UserSerializer, scope: {has_token: has_membership_token?})
  end

  private
  def current_user
    restricted_user || super
  end

  def model
    load_and_authorize(:group, optional: true) ||
    load_and_authorize(:discussion, optional: true) ||
    load_and_authorize(:poll, optional: true) ||
    load_and_authorize(:comment, optional: true) ||
    load_and_authorize(:stance, optional: true) ||
    load_and_authorize(:outcome, optional: true)
  end

  def accessible_records
    resource_class
  end

  def resource
    @user || current_user.presence || user_by_email
  end

  def user_by_email
    resource_class.active.verified_first.find_by(email: params[:email]) || LoggedOutUser.new(email: params[:email])
  end

  def deactivated_user
    resource_class.inactive.verified_first.find_by(email: params[:user][:email])
  end

  def current_user_params
    { user: current_user, actor: current_user, params: permitted_params.user }
  end

  def has_membership_token?
    return unless membership = Membership.find_by(token: params[:token])
    membership.token if resource.email == membership.user.email
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
