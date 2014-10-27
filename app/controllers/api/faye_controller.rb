class API::FayeController < API::BaseController
  def subscribe
    render json: PrivatePub.subscription(channel: '/events')
  end
end
