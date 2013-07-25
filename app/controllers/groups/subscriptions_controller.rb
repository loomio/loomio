class Groups::SubscriptionsController < GroupBaseController
  before_filter :load_group
  # TODO: Would be great if we can load_and_authorize_resource

  def new
    authorize! :choose_subscription_plan, @group
    @group = GroupDecorator.new @group
  end

  def checkout
    authorize! :choose_subscription_plan, @group
    @paypal = PaypalCheckout.new(group: @group, dollars: params['dollars'])
    @paypal.setup_payment_authorization
    redirect_to @paypal.gateway_url
  end

  def confirm
    authorize! :choose_subscription_plan, @group
    @paypal = PaypalConfirm.new(group: @group, dollars: params['dollars'], token: params['token'])
    @paypal.get_checkout_details
    @paypal.create_recurring_payments_profile
  end

  def view_payment_details
    authorize! :view_payment_details, @group
    @group = GroupDecorator.new @group
    redirect_to new_group_subscription_url unless @group.has_subscription_plan?
  end
end
