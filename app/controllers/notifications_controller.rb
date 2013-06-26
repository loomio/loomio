class NotificationsController < BaseController
  def groups_tree_dropdown
    render layout: false
  end

  def dropdown_items
    @unviewed_notifications = current_user.unviewed_notifications
    @notifications = current_user.recent_notifications
    render layout: false
  end

  def index
    @notifications = []
    @notifications = current_user.notifications.page(params[:page]).per(15)
  end

  def mark_as_viewed
    current_user.mark_notifications_as_viewed! params[:latest_viewed]
    head :ok
  end
end
