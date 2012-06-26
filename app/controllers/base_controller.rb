class BaseController < InheritedResources::Base
  before_filter :authenticate_user!, :check_browser, :get_notifications
  # inherit_resources

  def check_browser
    if browser.ie6? || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end

  def get_notifications
    if user_signed_in?
      @unviewed_notifications = current_user.unviewed_notifications
      # Do not show more than 10 notifications (unless they are unread)
      if @unviewed_notifications.size < 10
        @notifications = current_user.notifications.limit(10 - @unviewed_notifications.size)
      else
        @notifications = @unviewed_notifications
      end
    end
  end
end
