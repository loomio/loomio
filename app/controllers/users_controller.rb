class UsersController < BaseController
  def update
    update! { user_settings_url }
    flash[:notice] = "Your settings have been updated."
  end

  def settings
    @user = current_user
  end

  def dismiss_system_notice
    current_user.has_read_system_notice = true
    current_user.save!
    redirect_to :back
  end
end
