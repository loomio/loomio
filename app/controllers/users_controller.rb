class UsersController < BaseController
  def show
    @user = User.find_by_key!(params[:id])
    unless current_user.in_same_group_as?(@user)
      flash[:error] = t("error.cant_view_member_profile")
      redirect_to dashboard_path
    end
  end

  def update
    if current_user.update_attributes(permitted_params.user)
      Measurement.increment('users.update.success')
      set_application_locale
      flash[:notice] = t("notice.settings_updated")
      redirect_to dashboard_path
    else
      Measurement.increment('users.update.error')
      @user = current_user
      flash[:error] = t("error.settings_not_updated")
      render "profile"
    end
  end

  def upload_new_avatar
    new_uploaded_avatar = params[:uploaded_avatar]

    if new_uploaded_avatar
      current_user.avatar_kind = "uploaded"
      current_user.uploaded_avatar = new_uploaded_avatar
    end

    unless current_user.save
      flash[:error] = t("error.image_upload_fail")
    end
    redirect_to profile_url
  end

  def set_avatar_kind
    @avatar_kind = params[:avatar_kind]
    current_user.avatar_kind = @avatar_kind
    current_user.save!
    redirect_to profile_url
  end

  def profile
    @user = current_user
  end

  def dismiss_system_notice
    current_user.has_read_system_notice = true
    current_user.save!
    head :ok
  end
end
