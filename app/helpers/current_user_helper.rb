module CurrentUserHelper
  def current_user
    @current_user ||= token_user || super || restricted_user || LoggedOutUser.new
  end

  def current_visitor
    @current_visitor ||= Visitor.find_by(participation_token: cookies[:participation_token]) || Visitor.new
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
end
