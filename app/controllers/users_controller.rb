class UsersController < BaseController
  def update
    update! {:user_settings}
  end
  
  def settings
    @user = current_user
  end

end
