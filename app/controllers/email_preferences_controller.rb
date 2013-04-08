class EmailPreferencesController < BaseController
  skip_before_filter :authenticate_user!
  before_filter :authenticate_user_by_unsubscribe_token_or_fallback
  defaults :instance_name => 'email_preferences'

  def update
    update!(:notice => "Your email settings have been updated."){ root_url }
  end

  private

  def resource
    @email_preferences ||= EmailPreferences.new(@restricted_user || current_user)
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
