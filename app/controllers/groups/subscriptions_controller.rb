class Groups::SubscriptionsController < GroupBaseController
  before_filter :load_group
  before_filter :redirect_to_group_if_pwyc
  # TODO: Would be great if we can load_and_authorize_resource

  def new
    authorize! :choose_subscription_plan, @group
    if @group.has_subscription_plan?
      redirect_to view_payment_details_group_subscriptions_url(@group)
    end
  end

  def checkout
    authorize! :choose_subscription_plan, @group
    @paypal = PaypalCheckout.new(group: @group, amount: params['amount'])
    @paypal.setup_payment_authorization
    redirect_to @paypal.gateway_url
  end

  def confirm
    authorize! :choose_subscription_plan, @group
    @paypal = PaypalConfirm.new(group: @group,
                                amount: params['amount'],
                                token: params['token'])
    puts '<<<<<< get checkout details <<<<<<'
    @paypal.get_checkout_details
    puts @paypal.response.body
    puts '<<<<<< create recurring payments profile <<<<<<'
    @paypal.create_recurring_payments_profile
    puts @paypal.response.body
  end

  def view_payment_details
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
