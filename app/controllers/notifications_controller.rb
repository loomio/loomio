class NotificationsController < BaseController
  helper_method :unread_count
  skip_before_filter :boot_angular_ui, only: [:groups_tree_dropdown, :dropdown_items, :mark_as_viewed]

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
    Notification.beta_notifications.where(user_id: current_user.id).order('created_at DESC')
  end

  def unread_count
    Notification.beta_notifications.where(user_id: current_user.id, viewed: false).count
  end
end
