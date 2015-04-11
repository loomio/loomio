class API::NotificationsController < API::RestfulController

  def viewed
    current_user.update_attribute(:notifications_last_viewed_at, Time.zone.now)
    head :ok
  end

  private

  def visible_records
    Notification.where(user_id: current_user.id).order(created_at: :desc)
  end

end
