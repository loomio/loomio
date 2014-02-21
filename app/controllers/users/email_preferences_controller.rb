class Users::EmailPreferencesController < BaseController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_user_by_unsubscribe_token_or_fallback

  def edit
    load_email_preferences
  end

  def update
    load_email_preferences
    set_attributes
    if @email_preferences.update_attributes(@attributes)
      EmailPreferencesService.update_group_notification_preferences_for(@email_preferences.user, @group_email_preferences)
      flash[:notice] = "Your email settings have been updated."
      redirect_to root_url
    else
      flash[:error] = "Failed to update settings"
      render :edit
    end
  end


  private

  def load_email_preferences
    user = @restricted_user || current_user
    @email_preferences = user.email_preferences
  end

  def set_attributes
    @attributes = permitted_params.email_preferences
    if @email_preferences.user.beta_feature_enabled?('activity_summary_email')
      @attributes[:days_to_send] = @attributes[:days_to_send].reject(&:blank?)
    end
    @group_email_preferences = @attributes.delete(:group_email_preferences)
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
