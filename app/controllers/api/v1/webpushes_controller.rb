
class API::V1::WebpushesController < API::V1::RestfulController
  def index
    self.collection = [WebpushCert.first]
    respond_with_collection
  end

  def register_subscription
    if current_user.is_logged_in?
      WebpushSubscription.create(user_id: current_user.id,
                                 endpoint: params[:endpoint],
                                 p256dh: params[:keys][:p256dh],
                                 auth: params[:keys][:auth])

      return respond_ok
    end

    head :forbidden
  end

end
