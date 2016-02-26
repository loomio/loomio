class API::NotificationsController < API::RestfulController

  def viewed
    service.mark_as_viewed(current_user)
    head :ok
  end

  private

  def accessible_records
    resource_class.includes(event: [:eventable, :user]).where(user_id: current_user.id).order(created_at: :desc)
  end

end
