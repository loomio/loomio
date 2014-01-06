class PaypalCheckout
  include HTTParty
  include Routing
  include ReadableUnguessableUrlsHelper

  ENDPOINT_URL = ENV['PAYPAL_ENDPOINT_URL']

  attr_reader :response, :group

  def self.payment_description(amount, group)
    "#{group.name} group subscription - US$#{amount} monthly"
  end

  def initialize(group: nil, amount: nil)
    @amount = amount
    @group = group
  end

  def setup_payment_authorization
    @response = self.class.post(ENDPOINT_URL, body: setup_payment_query)
  end

  def setup_payment_query
    { user: ENV['PAYPAL_USERNAME'],
      pwd: ENV['PAYPAL_PASSWORD'],
      signature: ENV['PAYPAL_SIGNATURE'],
      method: "SetExpressCheckout",
      version: "98",
      l_billingtype0: "RecurringPayments",
      l_billingagreementdescription0: self.class.payment_description(@amount, @group),
      cancelurl: cancel_url,
      returnurl: return_url }
  end

  def gateway_url
    ENV['PAYPAL_GATEWAY_URL'] + token
  end

  def return_url
    confirm_group_subscription_url(@group, amount: @amount)
  end

  def cancel_url
    group_url(@group)
  end

  def token
    Rack::Utils.parse_nested_query(@response.body)['TOKEN']
  end

  def request
    #this is stub ReadableUnguessableUrlHelper call on request
  end
end
