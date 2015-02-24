class API::NotificationsController < API::RestfulController

  private

  def visible_records
    current_user.notifications.order(created_at: :desc)
  end

end
