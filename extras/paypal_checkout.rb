class PaypalCheckout
  include HTTParty
  include Routing

  ENDPOINT_URL = "https://api-3t.sandbox.paypal.com/nvp"
  DOLLAR_OPTIONS = %w[30 50 100 200]
  DOLLARS_TO_PEOPLE = {"30" => "10", "50" => "25", "100" => "50", "200" => "100"}

  attr_reader :response, :group

  def self.subscription_text_for(amount)
    I18n.t('payment_details.description', people: DOLLARS_TO_PEOPLE[amount], amount: amount)
  end

  def initialize(group: nil, amount: nil)
    raise StandardError unless DOLLAR_OPTIONS.include?(amount)
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
      l_billingagreementdescription0: payment_description,
      cancelurl: cancel_url,
      returnurl: return_url }
  end

  def gateway_url
    "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=#{token}"
  end

  def payment_description
    self.class.subscription_text_for(@amount)
  end

  def return_url
    confirm_group_subscriptions_url(@group, amount: @amount)
  end

  def cancel_url
    group_url(@group)
  end

  def token
    Rack::Utils.parse_nested_query(@response.body)['TOKEN']
  end
end
