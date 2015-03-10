class Users::EmailPreferencesController < AuthenticateByUnsubscribeTokenController
  helper_method :any_memberships_have_volume_email?

  def edit
    @user = user
  end

  def update
    @user = user

    if @user.update_attributes(permitted_params.user)
      if %w[loud normal quiet].include? params['set_group_volume']
        @user.memberships.update_all(volume: Membership.volumes[params['set_group_volume']])
      end

      flash[:notice] = "Your email settings have been updated."
      redirect_to dashboard_or_root_path
    else
      flash[:error] = "Failed to update settings"
      render :edit
    end
  end

  private
  def user
    @restricted_user || current_user
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
