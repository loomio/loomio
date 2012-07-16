class NotificationsController < BaseController
  def index
    @notifications = []
    if user_signed_in?
      @notifications = current_user.notifications
    end
  end

  def mark_as_viewed
    current_user.mark_notifications_as_viewed! params[:latest_viewed]
    redirect_to root_url
  end
end
