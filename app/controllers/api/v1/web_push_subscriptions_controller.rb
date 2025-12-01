class Api::V1::WebPushSubscriptionsController < Api::V1::RestfulController
  def create
    subscription = current_user.web_push_subscriptions.find_or_initialize_by(endpoint: subscription_params[:endpoint])
    subscription.assign_attributes(subscription_params)
    
    if subscription.save
      render json: { success: true, subscription: subscription }
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    subscription = current_user.web_push_subscriptions.find_by(endpoint: params[:endpoint])
    
    if subscription&.destroy
      render json: { success: true }
    else
      render json: { error: 'Subscription not found' }, status: :not_found
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:endpoint, :p256dh_key, :auth_key)
  end
end
