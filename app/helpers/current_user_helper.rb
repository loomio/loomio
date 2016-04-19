module CurrentUserHelper
  def current_user_or_visitor
    current_user || restricted_user || LoggedOutUser.new
  end

  private

  def current_user_serializer
    if current_user_or_visitor == restricted_user
      Restricted::UserSerializer
    else
      CurrentUserSerializer
    end
  end

  def restricted_user
    @restricted_user ||= User.find_by_unsubscribe_token(params[:unsubscribe_token]) if params[:unsubscribe_token]
  end

end
