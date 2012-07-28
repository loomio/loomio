class UsersController < BaseController

  def update
    current_user.name = params[:user][:name]
    current_user.avatar_kind = params[:user][:avatar_kind]
    new_uploaded_avatar = params[:user][:uploaded_avatar]

    if new_uploaded_avatar
      current_user.uploaded_avatar = new_uploaded_avatar
    end

    if current_user.save
      flash[:notice] = "Your settings have been updated."
      redirect_to :root
    else
      flash[:error] = "Unable to update user. Supported file types are jpeg, png, and gif."
      redirect_to :back
    end
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
