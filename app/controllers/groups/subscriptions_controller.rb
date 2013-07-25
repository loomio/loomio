class Groups::SubscriptionsController < GroupBaseController
  before_filter :require_current_user_is_group_admin
  before_filter :load_group

  def new
    @group = GroupDecorator.new @group
  end

  def checkout
    @paypal = PaypalCheckout.new(group: @group, dollars: params['dollars'])
    @paypal.setup_payment_authorization
    redirect_to @paypal.gateway_url
  end

  def confirm
    @paypal = PaypalConfirm.new(group: @group, dollars: params['dollars'], token: params['token'])
    @paypal.get_checkout_details
    @paypal.create_recurring_payments_profile
  end
end
