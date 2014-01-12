class Users::EmailPreferencesController < BaseController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_user_by_unsubscribe_token_or_fallback

  def edit
    load_email_preferences
  end

  def update
    load_email_preferences

    if EmailPreferencesService.update_preferences(@email_preferences, permitted_params.email_preferences)
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
    raise if user.nil?
    @email_preferences = user.email_preferences
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
