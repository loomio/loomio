class AuthenticateByUnsubscribeTokenController < ApplicationController
  before_action :authenticate_user_by_unsubscribe_token_or_fallback

  private

  def current_user
    @email_action_user || super
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    if params[:unsubscribe_token].present?
      @email_action_user = User.active.find_by(unsubscribe_token: params[:unsubscribe_token])
      respond_with_error 403 unless @email_action_user
    else
      authenticate_user!
    end
  end

  # Email action pages are Rails pages outside the Vue app, so show HTML errors without booting it.
  def respond_with_error(status, message = nil)
    return super unless request.format.html?

    render Views::Application::Error.new(title: t("errors.#{status}.title"), body: message || t("errors.#{status}.body")), status: status
  end
end
