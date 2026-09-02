class Api::V1::NotificationsController < Api::V1::RestfulController
  def index
    self.collection = NotificationQuery.currently_accessible_to(
      user: current_user,
      notifications: accessible_records.limit(50)
    )
    respond_with_collection
  end

  def viewed
    service.viewed(user: current_user)
    render json: { success: :ok }
  end

  def accessible_records
    NotificationQuery.delivered_to(user: current_user)
                     .includes(:actor, :subject, :notification_deliveries)
                     .order(id: :desc)
  end
end
