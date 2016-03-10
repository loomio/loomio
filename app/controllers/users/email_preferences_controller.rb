class Users::EmailPreferencesController < AuthenticateByUnsubscribeTokenController
  helper_method :any_memberships_have_volume_email?
  skip_before_filter :boot_angular_ui, only: :edit, if: :restricted_user

  def edit
  end

  def update
    if restricted_user.update_attributes(permitted_params.user)
      if %w[loud normal quiet].include? params[:set_group_volume]
        restricted_user.memberships.update_all(volume: Membership.volumes[params[:set_group_volume]])
      end

      # translate me!
      flash[:notice] = "Your email settings have been updated."
      redirect_to dashboard_or_root_path
    else
      flash[:error] = "Failed to update settings"
      render :edit
    end
  end

  private

  def restricted_user
    @restricted_user ||= User.find_by_unsubscribe_token(params[:unsubscribe_token]) if params[:unsubscribe_token]
  end

end
