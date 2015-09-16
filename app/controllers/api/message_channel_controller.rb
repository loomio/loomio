class API::MessageChannelController < API::RestfulController

  rescue_from(MessageChannelService::AccessDeniedError)   { |e| respond_with_standard_error e, 400 }
  rescue_from(MessageChannelService::UnknownChannelError) { |e| respond_with_standard_error e, 400 }

  def subscribe
    @subscriptions = [MessageChannelService.subscribe_to(user: current_user, channel: params[:channel])]
    respond_with_subscriptions
  end

  def subscribe_user
    @subscriptions = current_user.groups.map { |group| MessageChannelService.subscribe_to(user: current_user, channel: channel_for(group)) }
    @subscriptions <<                                  MessageChannelService.subscribe_to(user: current_user, channel: "/notifications-#{current_user.id}")
    respond_with_subscriptions
  end

  private

  def respond_with_subscriptions
    render json: @subscriptions, root: false
  end

  def channel_for(model)
    "/#{model.class.to_s.downcase}-#{model.key}"
  end
end
