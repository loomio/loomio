class API::NotificationsController < API::RestfulController
  def index
    instantiate_collection do |collection|
      collection.where(user_id: current_user.id).includes(:actor, :event).order(created_at: :desc).limit(30)
    end
    respond_with_collection
  end

  def viewed
    service.viewed(user: current_user)
    render json: { success: :ok }
  end

  private

  def accessible_records
    NotificationCollection.new(current_user).notifications
  end

end
