class UsersController < BaseController

  def update
    current_user.name = params[:user][:name]

    if current_user.save
      flash[:notice] = "Your settings have been updated."
      redirect_to :root
    else
      flash[:error] = "Your settings did not get updated."
      redirect_to :back
    end
  end

  def upload_new_avatar
    new_uploaded_avatar = params[:uploaded_avatar]

    if new_uploaded_avatar
      current_user.avatar_kind = "uploaded"
      current_user.uploaded_avatar = new_uploaded_avatar
    end

    unless current_user.save
      flash[:error] = "Unable to upload picture. Make sure the picture is under 1 MB and is a .jpeg, .png, or .gif file."
    end
    redirect_to :back
  end

  def set_avatar_kind
    current_user.avatar_kind = params[:avatar_kind]
    current_user.save
    respond_to do |format|
      format.html { redirect_to(root_url) }
      # format.js {}  template error
    end
  end

  def settings
    @user = current_user
  end

  def set_noise
    group_id = params[:group]
    noise_level = params[:noise]
    current_user.set_group_noise_level(group_id, noise_level)
    respond_to do |format|
      format.html { redirect_to(root_url) }
      # format.js {} template error
    end
  end

  def set_receive_emails
    current_user.receive_emails = params[:email]
    current_user.save!
    respond_to do |format|
      format.html { redirect_to(root_url) }
      # format.js {}
    end
  end

  def dismiss_system_notice
    current_user.has_read_system_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_dashboard_notice
    current_user.has_read_dashboard_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_group_notice
    current_user.has_read_group_notice = true
    current_user.save!
    redirect_to :back
  end

  def dismiss_discussion_notice
    current_user.has_read_discussion_notice = true
    current_user.save!
    redirect_to :back
  end
end
