class API::NotificationsController < API::RestfulController
  def index
    @notifications = current_user.notifications.order(created_at: :desc).page(params[:page]).per(10).to_a
    respond_with_collection
  end
end
