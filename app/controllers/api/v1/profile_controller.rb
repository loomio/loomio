class Api::V1::ProfileController < Api::V1::RestfulController
  before_action :require_current_user

  def index
    ids = UserQuery.invitable_user_ids(model: nil, actor: current_user, user_ids: params[:xids].split('x').map(&:to_i).compact)
    self.collection = User.where(id: ids)
    cache = RecordCache.for_collection(collection, current_user.id, exclude_types)
    respond_with_collection serializer: AuthorSerializer, root: :users, scope: {cache: cache, exclude_types: exclude_types}
  end

  def show
    load_and_authorize :user
    respond_with_resource serializer: UserSerializer
  end

  def groups
    self.collection = GroupQuery.visible_to(user: current_user)

    cache = RecordCache.for_collection(collection, current_user.id, exclude_types)

    respond_with_collection serializer: GroupSerializer, root: :groups, scope: {
      cache: cache,
      current_user_id: current_user.id,
      exclude_types: exclude_types
    }
  end

  def time_zones
    time_zones = User.where('time_zone is not null').joins(:memberships).
                      where('memberships.group_id': current_user.group_ids).
                      group(:time_zone).count.sort_by {|k,v| -v }
    render json: time_zones, root: false
  end

  def all_time_zones
    zones = ActiveSupport::TimeZone.all.map do |tz|
      {
        title: I18n.t("timezones.#{tz.name}", default: tz.name, locale: params[:selected_locale]),
        value: tz.tzinfo.name
      }
    end
    render json: zones, root: false
  end

  def me
    raise CanCan::AccessDenied.new unless current_user.is_logged_in?
    self.resource = current_user
    respond_with_resource serializer: UserSerializer
  end

  def email_api_key
    render json: {email_api_key: current_user.email_api_key}
  end

  def reset_email_api_key
    current_user.update_attribute(:email_api_key, User.generate_unique_secure_token)
    render json: {email_api_key: current_user.email_api_key}
  end

  def remind
    service.remind(user: load_resource, actor: current_user, model: load_and_authorize(:poll))
    respond_with_resource
  end

  def update_profile
    service.update(**current_user_params)
    respond_with_resource
  end

  def set_volume
    service.set_volume(
      user: current_user,
      actor: current_user,
      params: params.slice(:volume_email, :volume_push, :apply_to_all)
    )
    respond_with_resource
  end

  def upload_avatar
    service.update user: current_user, actor: current_user, params: { uploaded_avatar: params[:file], avatar_kind: :uploaded }
    respond_with_resource
  end

  def avatar_uploaded
    identity = provider_picture_identity
    render json: {
      avatar_uploaded: current_user.uploaded_avatar_url,
      provider_picture: identity && { provider: provider_name(identity) }
    }
  end

  def use_provider_avatar
    raise CanCan::AccessDenied if UserService.disable_edit_user_profile?

    identity = provider_picture_identity
    raise ActiveRecord::RecordNotFound unless identity

    identity.assign_logo!
    respond_with_resource
  end

  def deactivate
    service.deactivate(user: current_user, actor: current_user)
    respond_with_resource
  end

  def destroy
    service.redact(user: current_user, actor: current_user)
    respond_with_resource
  end

  def save_experience
    raise ActionController::ParameterMissing.new(:experience) unless params.has_key?(:experience)
    service.save_experience(user: current_user, actor: current_user, params: params)
    respond_with_resource
  end

  def send_merge_verification_email
    unless ThrottleService.can?(key: 'MergeVerificationEmail', id: current_user.id, max: 5, per: 'hour')
      render json: { error: 'Rate limit exceeded' }, status: 429
      return
    end
    MergeUsersService.send_merge_verification_email(actor: current_user, target_email: params[:target_email])
    success_response
  end

  def contactable
    render json: {
      contactable: current_user.can?(:contact, User.find(params[:user_id]))
    }
  end

  private

  def provider_picture_identity
    current_user.identities.where.not(logo: [ nil, '' ]).first
  end

  def provider_name(identity)
    return AppConfig.theme[:oauth_login_provider_name] if identity.identity_type == 'oauth'

    identity.identity_type.titleize
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
    resource_class.active.find_by(email: params[:email]) || LoggedOutUser.new(email: params[:email])
  end

  def deactivated_user
    resource_class.deactivated.find_by(email: params[:user][:email])
  end

  def current_user_params
    { user: current_user, actor: current_user, params: profile_update_params }
  end

  def profile_update_params
    profile_params = permitted_params.user
    profile_params = profile_params.except(:password, :password_confirmation, :current_password) unless AppConfig.local_login_enabled?
    profile_params
  end

  def resource_class
    User
  end

  def serializer_class
    CurrentUserSerializer
  end

  def serializer_root
    :users
  end

  def service
    UserService
  end
end
