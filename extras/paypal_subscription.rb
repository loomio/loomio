class PaypalSubscription
  include HTTParty
  include Routing

  attr_reader :recurring_payments_response, :checkout_details_response, :token

  def initialize(group: nil, amount: nil, token: nil)
    raise "invalid amount: #{amount.inspect}" unless PaypalCheckout::AMOUNT_OPTIONS.include?(amount)
    @group = group
    @token = token
    @amount = amount
  end

  def get_checkout_details
    @checkout_details_response = self.class.post(PaypalCheckout::ENDPOINT_URL,
                                body: get_checkout_details_query)
  end

  def create_recurring_payment
    @recurring_payments_response = self.class.post(PaypalCheckout::ENDPOINT_URL,
                                body: create_recurring_payment_query)
  end

  def payer_id
    Rack::Utils.parse_nested_query(@checkout_details_response.body)['PAYERID']
  end

  def profile_id
    Rack::Utils.parse_nested_query(@recurring_payments_response.body)['PROFILEID']
  end

  def success?
    (Rack::Utils.parse_nested_query(@recurring_payments_response.body)['ACK'] == "Success")
  end

  def get_checkout_details_query
    { user: ENV['PAYPAL_USERNAME'],
      pwd: ENV['PAYPAL_PASSWORD'],
      signature: ENV['PAYPAL_SIGNATURE'],
      method: "GetExpressCheckoutDetails",
      version: "98",
      token: @token }
  end

  def create_recurring_payment_query
    { user: ENV['PAYPAL_USERNAME'],
      pwd: ENV['PAYPAL_PASSWORD'],
      signature: ENV['PAYPAL_SIGNATURE'],
      method: "CreateRecurringPaymentsProfile",
      version: "98",
      payerid: payer_id,
      profilestartdate: start_time,
      desc: PaypalCheckout.payment_description(@amount),
      billingperiod: "Month",
      billingfrequency: "1",
      amt: @amount,
      currencycode: "USD",
      maxfailedpayments: "3",
      autobilloutamt: "AddToNextBilling",
      token: @token }
  end

  def start_time
    (Time.now + 5.minutes).utc.iso8601
  end
end
