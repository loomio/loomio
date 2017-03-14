module CurrentUserHelper
  def current_user
    @current_user ||= visitor_user || token_user || super || restricted_user || LoggedOutUser.new
  end

  private

  def token_user
    return unless doorkeeper_token.present?
    doorkeeper_render_error unless valid_doorkeeper_token?
    @token_user ||= User.find(doorkeeper_token.resource_owner_id)
  end

  def restricted_user
    @restricted_user ||= User.find_by(unsubscribe_token: params[:unsubscribe_token]) if params[:unsubscribe_token]
  end

  def visitor_user
    @visitor_user ||= Visitor.find_by(participation_token: cookies[:participation_token]) if cookies[:participation_token]
  end
end
