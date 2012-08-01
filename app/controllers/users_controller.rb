class UsersController < BaseController

  def update
    current_user.name = params[:user][:name]
    new_uploaded_avatar = params[:user][:uploaded_avatar]

    if new_uploaded_avatar
      current_user.avatar_kind = params[:user][:avatar_kind]
      current_user.uploaded_avatar = new_uploaded_avatar
    end

    success = current_user.save
    if success && (not new_uploaded_avatar)
      flash[:notice] = "Your settings have been updated."
      redirect_to :root
    else
      flash[:error] = "Unable to update user. Supported file types are jpeg, png, and gif." unless success
      redirect_to :back
    end
  end

  def set_avatar_kind
    current_user.avatar_kind = params[:avatar_kind]
    current_user.save
    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.js {}
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
