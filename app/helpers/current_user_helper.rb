module CurrentUserHelper
  def current_user_or_visitor
    if user_signed_in?
      current_user
    else
      LoggedOutUser.new
    end
  end
end
