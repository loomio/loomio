class API::MessageChannelController < API::RestfulController

  rescue_from(MessageChannelService::AccessDeniedError)   { |e| respond_with_standard_error e, 400 }
  rescue_from(MessageChannelService::UnknownChannelError) { |e| respond_with_standard_error e, 400 }

  def subscribe
    @subscriptions = Array(subscription_models).map { |model| MessageChannelService.subscribe_to(user: current_user, model: model) }.compact
    respond_with_subscriptions
  end

  private

  def respond_with_subscriptions
    render json: @subscriptions, root: false
  end

  def subscription_models
    (params[:group_key] && load_and_authorize(:group)) ||
    (params[:discussion_key] && load_and_authorize(:discussion)) ||
    subscriptions_for_user
  end

  def subscriptions_for_user
    Array(current_user) + Array(current_user.groups) + Array(GlobalMessageChannel.instance)
  end

end
