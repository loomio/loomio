class API::NotificationsController < API::RestfulController
  def index
    instantiate_collection do |collection|
      collection.limit(30)
    end
    respond_with_collection
  end

  def viewed
    service.viewed(user: current_user)
    render json: { success: :ok }
  end

  def accessible_records
    current_user.notifications.includes(:actor, :event).order(id: :desc)
  end

  def default_scope
    super.merge(cache: RecordCache.for_notifications(collection, exclude_types))
  end
end
