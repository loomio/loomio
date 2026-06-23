class Api::B3::UsersController < Api::V1::SnorlaxBase
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key!
  include ::LoadAndAuthorize

  USER_UPDATE_FIELDS = [:name, :username, :email]

  def authenticate_api_key!
    api_key = ENV.fetch('B3_API_KEY', '')
    raise CanCan::AccessDenied unless api_key.length > 16
    raise CanCan::AccessDenied unless api_key_param == api_key || bearer_token == api_key
  end

  def index
    render json: {users: User.includes(:identities).order(:id).map { |user| user_json(user) }}
  end

  def show
    render json: {user: user_json(user)}
  end

  def show_by_identity
    render json: {user: user_json(user_by_identity)}
  end

  def update
    update_user(user)
  end

  def update_by_identity
    update_user(user_by_identity)
  end

  def deactivate
    deactivate_user(user_scope.active.find(params[:id]))
  end

  def deactivate_by_identity
    deactivate_user(user_by_identity(active: true))
  end

  def reactivate
    reactivate_user(user_scope.deactivated.find(params[:id]))
  end

  def reactivate_by_identity
    reactivate_user(user_by_identity(deactivated: true))
  end

  def destroy
    destroy_user(user)
  end

  def destroy_by_identity
    destroy_user(user_by_identity)
  end

  private

  def api_key_param
    params[:b3_api_key].to_s
  end

  def bearer_token
    request.authorization.to_s[/\ABearer (.+)\z/, 1].to_s
  end

  def user_scope
    User.includes(:identities)
  end

  def user
    @user ||= user_scope.find(params[:id])
  end

  def user_by_identity(active: false, deactivated: false)
    identity = Identity.with_user.find_by!(
      identity_type: params[:identity_type],
      uid: params[:uid]
    )

    scope = user_scope
    scope = scope.active if active
    scope = scope.deactivated if deactivated
    scope.find(identity.user_id)
  end

  def update_user(user)
    user.update!(user_params)
    render json: {user: user_json(user.reload)}
  end

  def deactivate_user(user)
    DeactivateUserWorker.perform_later(user.id, user.id)
    render json: {success: true, user: user_json(user.reload)}
  end

  def reactivate_user(user)
    UserService.reactivate(user.id)
    render json: {success: true, user: user_json(user.reload)}
  end

  def destroy_user(user)
    RedactUserWorker.perform_later(user.id, user.id)
    render json: {success: true}
  end

  def user_params
    params.require(:user).permit(*USER_UPDATE_FIELDS)
  end

  def user_json(user)
    {
      id: user.id,
      name: user.name,
      username: user.username,
      email: user.email,
      active: user.deactivated_at.blank?,
      deactivated_at: user.deactivated_at&.iso8601,
      identities: user.identities.map { |identity| identity_json(identity) }
    }
  end

  def identity_json(identity)
    {
      id: identity.id,
      identity_type: identity.identity_type,
      uid: identity.uid,
      email: identity.email,
      name: identity.name
    }
  end
end
