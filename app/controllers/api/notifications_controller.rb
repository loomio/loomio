class API::NotificationsController < API::RestfulController

  def viewed
    service.viewed(user: current_user)
    head :ok
  end

  private

  def accessible_records
    NotificationCollection.new(current_user).notifications
  end

end
