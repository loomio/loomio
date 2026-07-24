class Api::V1::ProfileController < Api::V1::RestfulController
  # A "restricted" current_user is one authenticated ONLY by an unsubscribe_token
  # (a permanent bearer token embedded in every notification email), not by a
  # real session. Such a request may manage email/notification preferences, but
  # must NEVER reach account-destructive or credential-bearing actions, nor edit
  # identity fields (name/email/password/username/avatar) via update_profile.
  RESTRICTED_USER_FORBIDDEN_ACTIONS = %w[
    email_api_key reset_email_api_key deactivate destroy
    send_merge_verification_email remind upload_avatar
  ].freeze

  # The only user fields update_profile may change for a restricted user.
  RESTRICTED_USER_UPDATABLE_FIELDS = %i[
    email_when_mentioned email_when_proposal_closing_soon
    email_new_discussions_and_proposals email_on_participation
    email_newsletter email_catch_up_day default_membership_volume
    selected_locale autodetect_time_zone time_zone date_time_pref
    email_new_discussions_and_proposals_group_ids
  ].freeze

  before_action :require_current_user, except: [:email_status]
  before_action :forbid_restricted_user_actions

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

    respond_with_collection serializer: GroupSerializer, root: :groups, scope: {cache: cache, exclude_types: exclude_types}
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
    service.set_volume(user: current_user, actor: current_user, params: params.slice(:volume, :apply_to_all))
    respond_with_resource
  end

  def upload_avatar
    service.update user: current_user, actor: current_user, params: { uploaded_avatar: params[:file], avatar_kind: :uploaded }
    respond_with_resource
  end

  def avatar_uploaded
    render json: {avatar_uploaded: current_user.uploaded_avatar_url}
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

  def email_status
    respond_with_resource(serializer: Pending::UserSerializer, scope: {})
  end

  def email_exists
    render json: {email: params[:email], exists: User.where(email: params[:email]).any?}
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
    current_user.ability.authorize!(:contact, User.find(params[:user_id]))
    success_response
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
    resource_class.active.find_by(email: params[:email]) || LoggedOutUser.new(email: params[:email])
  end

  def deactivated_user
    resource_class.deactivated.find_by(email: params[:user][:email])
  end

  def current_user_params
    { user: current_user, actor: current_user, params: profile_update_params }
  end

  def profile_update_params
    return permitted_params.user unless current_user.restricted

    # Restricted (unsubscribe-token) users may only update notification prefs —
    # strip identity/credential fields so the token cannot be used to change
    # name, email, password, username, or avatar.
    permitted_params.user.slice(*RESTRICTED_USER_UPDATABLE_FIELDS.map(&:to_s))
  end

  def forbid_restricted_user_actions
    return unless RESTRICTED_USER_FORBIDDEN_ACTIONS.include?(action_name) && current_user.restricted

    raise CanCan::AccessDenied.new("unsubscribe-token users may not perform #{action_name}")
  end

  def resource_class
    User
  end

  def serializer_class
    if current_user.restricted
      Restricted::UserSerializer
    else
      CurrentUserSerializer
    end
  end

  def serializer_root
    :users
  end

  def service
    UserService
  end
end
