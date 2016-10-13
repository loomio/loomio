class API::NotificationsController < API::RestfulController

  def viewed
    NotificationService.mark_as_viewed(current_user)
    head :ok
  end

  private

  def accessible_records
    Notification.includes(event: [:eventable, :user]).where(user_id: current_user.id).order(created_at: :desc)
  end

end
