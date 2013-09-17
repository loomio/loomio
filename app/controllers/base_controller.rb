class BaseController < ApplicationController
  include AutodetectTimeZone
  before_filter :authenticate_user!, :check_browser, :check_for_invitation, :load_announcements
  before_filter :set_time_zone_from_javascript
  helper_method :time_zone

  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user)
  end
  helper_method :permitted_params

  protected

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
