class API::NotificationsController < API::RestfulController

  def viewed
    service.mark_as_viewed(current_user)
    head :ok
  end

end
