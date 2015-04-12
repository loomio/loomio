class API::MessageChannelController < API::BaseController
  def subscribe
    render json: MessageChannelService.subscribe_to(user: current_user, channel: params[:channel])
  rescue MessageChannelService::AccessDeniedError => e
    render json: {error: "access denied error: #{e.inspect}"}, root: false, status: 400
  end
end
