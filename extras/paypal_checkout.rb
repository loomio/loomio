class PaypalCheckout
  include HTTParty
  include Routing

  ENDPOINT_URL = ENV['PAYPAL_ENDPOINT_URL']
  DOLLARS_TO_PEOPLE = {30 => 10, 50 => 25, 100 => 50, 200 => 100}
  AMOUNT_OPTIONS = DOLLARS_TO_PEOPLE.keys

  attr_reader :response, :group

  def self.payment_description(amount)
    "Group plan: Up to #{DOLLARS_TO_PEOPLE[amount]} people (US$#{amount} monthly)"
  end

  def initialize(group: nil, amount: nil)
    raise "invalid amount: #{amount.inspect}" unless PaypalCheckout::AMOUNT_OPTIONS.include?(amount)
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
      l_billingagreementdescription0: self.class.payment_description(@amount),
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
end
