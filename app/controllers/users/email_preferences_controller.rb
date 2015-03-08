class Users::EmailPreferencesController < AuthenticateByUnsubscribeTokenController
  helper_method :any_memberships_have_volume_email?

  def edit
    @user = user
  end

  def update
    @user = user

    if any_memberships_have_volume_email? and
      params[:email_new_discussions_and_proposals].nil?
      @user.memberships.where(volume: Membership.volumes[:email]).
                        update_all(volume: Membership.volumes[:normal])
    end

    if @user.email_on_participation? and
       params[:email_on_participation].nil?
      @user.discussion_readers.where(volume: DiscussionReader.volumes[:email]).
                               update_all(volume: DiscussionReader.volumes[:normal])
    end

    if @user.update_attributes(permitted_params.user)
      flash[:notice] = "Your email settings have been updated."
      redirect_to dashboard_or_root_path
    else
      flash[:error] = "Failed to update settings"
      render :edit
    end
  end

  private
  def any_memberships_have_volume_email?
    @user.memberships.where(volume: Membership.volumes[:email]).any?
  end

  def user
    @restricted_user || current_user
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
