class API::NotificationsController < API::RestfulController

  def viewed
    service.viewed(user: current_user)
    head :ok
  end

end
