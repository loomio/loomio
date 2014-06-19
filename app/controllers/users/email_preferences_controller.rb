class Users::EmailPreferencesController < BaseController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_user_by_unsubscribe_token_or_fallback

  def edit
    resource
  end

  def update
    resource
    if resource.update_attributes(permitted_params.email_preferences)
      flash[:notice] = "Your email settings have been updated."
      redirect_to dashboard_or_root_path
    else
      flash[:error] = "Failed to update settings"
      render :edit
    end
  end

  def mark_summary_email_as_read
    @inbox = Inbox.new(user)
    @inbox.load
    time = Time.at(params[:email_timestamp].to_i).utc
    @inbox.clear_all_in_group(user.inbox_groups, time)
    flash[:notice] = I18n.t "email.missed_yesterday.marked_as_read_success"
    redirect_to dashboard_or_root_path
  end

  private

  def user
    @restricted_user || current_user
  end

  def resource
    @email_preferences ||= EmailPreferences.new(@restricted_user || current_user)
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
