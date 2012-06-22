class BaseController < InheritedResources::Base
  before_filter :authenticate_user!, :check_browser, :get_notifications
  # inherit_resources

  def check_browser
    if browser.ie6? || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end

  def get_notifications
    @notifications = Notification.where("user_id = ?", current_user.id)
  end
end
