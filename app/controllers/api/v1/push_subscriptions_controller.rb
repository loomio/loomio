class Api::V1::PushSubscriptionsController < Api::V1::RestfulController
  before_action :require_current_user

  def index
    self.collection = current_user.push_subscriptions.active.order(created_at: :desc)
    respond_with_collection
  end

  def create
    self.resource = PushSubscriptionService.create_or_update!(
      session: Current.session,
      params: subscription_params,
      user_agent: request.user_agent
    )
    respond_with_resource
  end

  def destroy
    PushSubscriptionService.revoke!(
      session: Current.session,
      endpoint: params[:endpoint],
      id: params[:id]
    )
    respond_ok
  end

  private

  def subscription_params
    params.require(:push_subscription).permit(
      :endpoint,
      :p256dh_key,
      :auth_key,
      :expires_at,
      :name
    ).to_h.symbolize_keys
  end
end
