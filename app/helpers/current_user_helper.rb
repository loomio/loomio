module CurrentUserHelper
  def current_user_or_visitor
    @current_user_or_visitor ||= current_user || restricted_user || LoggedOutUser.new
  end

  def user_is_restricted?
    current_user.nil? && current_user_or_visitor == restricted_user
  end

  private

  def restricted_user
    @restricted_user ||= User.find_by_unsubscribe_token(params[:unsubscribe_token]) if params[:unsubscribe_token]
  end

end
