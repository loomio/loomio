class API::FayeController < API::BaseController
  def subscribe
    render json: PrivatePub.subscription(channel: '/events')
  end

  def who_am_i
    render json: current_user, serializer: AuthorSerializer
  end
end
