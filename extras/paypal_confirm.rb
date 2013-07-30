class PaypalConfirm
  include HTTParty
  include Routing

  attr_reader :response

  def initialize(group: nil, amount:nil, token: nil)
    raise StandardError unless PaypalCheckout::DOLLAR_OPTIONS.include?(amount)
    @group = group
    @token = token
    @amount = amount
  end

  def get_checkout_details
    @response = self.class.post(PaypalCheckout::ENDPOINT_URL,
                                body: get_checkout_details_query)
  end

  def payer_id
    Rack::Utils.parse_nested_query(@response.body)['PAYERID']
  end

  def get_checkout_details_query
    { user: ENV['PAYPAL_USERNAME'],
      pwd: ENV['PAYPAL_PASSWORD'],
      signature: ENV['PAYPAL_SIGNATURE'],
      method: "GetExpressCheckoutDetails",
      version: "98",
      token: @token }
  end

  def create_recurring_payments_profile
    @response = self.class.post(PaypalCheckout::ENDPOINT_URL,
                                body: create_recurring_payments_profile_query)
  end

  def create_recurring_payments_profile_query
    { user: ENV['PAYPAL_USERNAME'],
      pwd: ENV['PAYPAL_PASSWORD'],
      signature: ENV['PAYPAL_SIGNATURE'],
      method: "CreateRecurringPaymentsProfile",
      version: "98",
      payerid: payer_id,
      profilestartdate: (Time.now + 5.minutes).utc.iso8601,
      desc: I18n.t('payment_details.description',
                   people: PaypalCheckout::DOLLARS_TO_PEOPLE[@amount],
                   amount: @amount),
      billingperiod: "Month",
      billingfrequency: "1",
      amt: @amount,
      currencycode: "USD",
      maxfailedpayments: "3",
      autobilloutamt: "AddToNextBilling",
      token: @token }
  end
end
