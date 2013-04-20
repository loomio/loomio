class BaseController < ApplicationController
  inherit_resources
  before_filter :authenticate_user!, :check_browser, :check_for_invitation, :get_notifications

  private
  def check_browser
    if browser.ie6? # || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end

  def check_for_invitation
    if session[:invitation_token] and current_user
      redirect_to invitation_path(session[:invitation_token])
    end
  end

  def get_notifications
    if user_signed_in?
      @unviewed_notifications = current_user.unviewed_notifications
      @notifications = current_user.recent_notifications
    end
  end

end
