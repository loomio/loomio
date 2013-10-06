class Groups::SubscriptionsController < GroupBaseController
  before_filter :load_group
  # TODO: Would be great if we can load_and_authorize_resource

  def new
    authorize! :choose_subscription_plan, @group
    if @group.has_subscription_plan?
      redirect_to group_subscription_url @group
    end
    @subscription_form = SubscriptionForm.new
  end

  def checkout
    authorize! :choose_subscription_plan, @group
    @subscription_form = SubscriptionForm.new(params[:subscription_form])
    if @subscription_form.valid?
      if @subscription_form.amount.to_f <= 0
        subscription = Subscription.create!(group: @group, amount: 0)
        flash[:success] = "Thank you! Your $0 subscription is now set up."
        redirect_to group_subscription_url(@group)
      else
        @paypal = PaypalCheckout.new(group: @group, amount: @subscription_form.amount_with_cents)
        @paypal.setup_payment_authorization
        redirect_to @paypal.gateway_url
      end
    else
      flash[:error] = "Custom amount was invalid. Please enter a number above 0."
      render 'new'
    end
  end

  def confirm
    authorize! :choose_subscription_plan, @group
    amount = params['amount']
    @paypal = PaypalSubscription.new(group: @group,
                                amount: amount,
                                token: params['token'])
    @paypal.get_checkout_details
    @paypal.create_recurring_payment
    if @paypal.success?
      subscription = Subscription.create!(group: @group, amount: amount, profile_id: @paypal.profile_id)
      @group.reload
      flash[:success] = "Thank you! Your subscription payment is now set up. You'll be billed monthly starting today."
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
end
