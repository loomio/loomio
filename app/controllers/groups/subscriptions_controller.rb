class Groups::SubscriptionsController < GroupBaseController
  before_filter :load_group
  before_filter :redirect_to_group_if_pwyc
  # TODO: Would be great if we can load_and_authorize_resource

  def new
    authorize! :choose_subscription_plan, @group
    if @group.has_subscription_plan?
      redirect_to group_subscription_url(@group)
    end
  end

  def create
    authorize! :choose_subscription_plan, @group
    @paypal = PaypalCheckout.new(group: @group, amount: params['amount'].to_i)
    @paypal.setup_payment_authorization
    redirect_to @paypal.gateway_url
  end

  def confirm
    authorize! :choose_subscription_plan, @group
    amount = params['amount'].to_i
    @paypal = PaypalSubscription.new(group: @group,
                                amount: amount,
                                token: params['token'])
    @paypal.get_checkout_details
    @paypal.create_recurring_payment
    if @paypal.success?
      @group.subscription = Subscription.new(amount: amount, profile_id: @paypal.profile_id)
      @group.save!
      @group.reload
      flash[:success] = t(:'subscriptions.payment_success_flash_notice')
      redirect_to group_subscription_url(@group)
    else
      redirect_to payment_failed_group_subscription_url(@group)
    end
  end

  def payment_failed
  end

  def show
    authorize! :view_payment_details, @group
    unless @group.has_subscription_plan?
      redirect_to new_group_subscription_url(@group)
    end
  end

  private

  def redirect_to_group_if_pwyc
    redirect_to @group unless @group.paying_subscription?
  end
end
