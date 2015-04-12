class NotificationsController < BaseController
  helper_method :unread_count

  def groups_tree_dropdown
    render layout: false
  end

  def dropdown_items
    @notifications = notifications.includes(event: [:eventable, :user]).limit(12)
    render layout: false
  end

  def index
    @notifications = notifications.includes(event: [:eventable, :user])
                     .page(params[:page]).per(15)
  end

  def mark_as_viewed
    NotificationService.mark_as_viewed(current_user)
    head :ok
  end

  private
  def notifications
    Notification.where(user_id: current_user.id).order('created_at DESC')
  end

  def unread_count
    Notification.where(user_id: current_user.id, viewed: false).count
  end

  # Returns most recent notifications
  #   lower_limit - (minimum # of notifications returned)
  #   upper_limit - (maximum # of notifications returned)
  def recent_notifications(lower_limit=10, upper_limit=25)
    if current_user.unviewed_notifications.count < lower_limit
      current_user.notifications.limit(lower_limit)
    else
      current_user.unviewed_notifications.limit(upper_limit)
    end
  end
end
