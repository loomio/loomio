class UsersController < BaseController
  def update
    #TODO testing - reroute to settings page
    #@user.avatar = nil if @user && @user.avatar
    
    update! {root_url}
  end
  def settings
    @user = current_user
  end

end
