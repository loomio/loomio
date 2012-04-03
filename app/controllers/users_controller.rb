class UsersController < BaseController
  def update
    update! {root_url}
  end
  def settings
    @user = current_user
  end

end
