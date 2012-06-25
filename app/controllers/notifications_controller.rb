class NotificationsController < BaseController
  def index
    @notifications = []
    if user_signed_in?
      current_user.mark_notifications_as_viewed!
      @notifications = current_user.notifications
    end
  end
end
