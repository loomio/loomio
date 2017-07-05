module CurrentUserHelper
  def current_user
    @current_user ||= token_user || super || restricted_user || LoggedOutUser.new
  end

  private

  def token_user
    return unless doorkeeper_token.present?
    doorkeeper_render_error unless valid_doorkeeper_token?
    User.find(doorkeeper_token.resource_owner_id)
  end

  def restricted_user
    User.find_by!(params.slice(:unsubscribe_token)).tap { |user| user.restricted = true } if params[:unsubscribe_token]
  end

  def set_invitation_token
    current_user.token = params[:invitation_token] if params[:invitation_token]
  end
end
