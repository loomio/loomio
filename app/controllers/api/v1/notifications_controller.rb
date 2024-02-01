class API::V1::NotificationsController < API::V1::RestfulController
  def index
    self.collection = accessible_records.limit(50).select do |notification|
      current_user.can? :show, notification.event.eventable
    end
    respond_with_collection
  end

  def viewed
    service.viewed(user: current_user)
    render json: { success: :ok }
  end

  def accessible_records
    current_user.notifications.includes(:actor, event: :eventable).order(id: :desc)
  end
end
