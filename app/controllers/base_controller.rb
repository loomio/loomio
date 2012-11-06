class BaseController < InheritedResources::Base
  before_filter :site_down
  # inherit_resources

  def site_down
    redirect_to page_url("site_down")
  end

  def check_browser
    if browser.ie6? # || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end

  def get_notifications
    if user_signed_in?
      @unviewed_notifications = current_user.unviewed_notifications
      @notifications = current_user.recent_notifications
    end
  end
end
