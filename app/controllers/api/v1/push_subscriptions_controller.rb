class Api::V1::PushSubscriptionsController < Api::V1::RestfulController
  def index
    render json: { push_subscriptions: serialize(current_user.push_subscriptions) }
  end

  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(endpoint: subscription_params[:endpoint])
    subscription.assign_attributes(subscription_params)

    if subscription.save
      render json: { push_subscriptions: [serialize_one(subscription)] }
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    subscription = current_user.push_subscriptions.find(params[:id])
    if subscription.update(subscription_params)
      render json: { push_subscriptions: [serialize_one(subscription)] }
    else
      render json: { errors: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    subscription = current_user.push_subscriptions.find_by(endpoint: params[:endpoint]) ||
                   current_user.push_subscriptions.find_by(id: params[:id])

    if subscription&.destroy
      render json: { success: true }
    else
      render json: { error: 'Subscription not found' }, status: :not_found
    end
  end

  private

  def serialize(subscriptions)
    subscriptions.map { |s| serialize_one(s) }
  end

  def serialize_one(subscription)
    {
      id: subscription.id,
      user_id: subscription.user_id,
      endpoint: subscription.endpoint,
      name: subscription.name,
      created_at: subscription.created_at
    }
  end

  def subscription_params
    params.require(:subscription).permit(:endpoint, :p256dh_key, :auth_key, :name)
  end
end
