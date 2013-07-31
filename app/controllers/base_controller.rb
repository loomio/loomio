class BaseController < ApplicationController
  include AutodetectTimeZone
  before_filter :authenticate_user!, :check_browser, :check_for_invitation, :load_announcements
  before_filter :set_time_zone_from_javascript
  helper_method :time_zone

  protected

  def time_zone
    if user_signed_in?
      current_user.time_zone
    else
      'UTC'
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_stored_location
    session[:return_to] = nil
  end

  def after_sign_in_path_for(resource)
    path = session[:return_to] || root_path
    clear_stored_location
    path
  end

  def load_announcements
    if current_user and not request.xhr?
      @current_and_not_dismissed_announcements = Announcement.current_and_not_dismissed_by(current_user)
    end
  end

  def check_browser
    if browser.ie6? # || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end

  def check_for_invitation
    if session[:invitation_token] and user_signed_in?
      redirect_to invitation_path(session[:invitation_token])
    end
  end
end
