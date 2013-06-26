class SwipeWrapper
  include HTTParty
  format :json
  CURRENCIES = ['USD', 'NZD', 'CNY', 'HKD', 'GBP', 'AUD', 'JPY', 'CAD', 'SGD', 'ZAR', 'EUR', 'KRW']

  def create_tx_identifier_for(params)
    @amount = params[:amount]
    @currency = params[:currency]
    @user = params[:user]
    response = self.class.post(swipe_url, query: query_params)
    parse_identifier_from_response(response)
  end

  def currency=(c)
    @currency = c.upcase
  end

  def currency
    if CURRENCIES.include? @currency
     @currency
    else
      CURRENCIES.first
    end
  end

  private

  def parse_identifier_from_response(response)
    response["data"]["identifier"]
  end

  def swipe_url
    ENV["SWIPE_PAYMENT_URL"]
  end

  def query_params
    {
      api_key: ENV["SWIPE_API_KEY"],
      merchant_id: ENV["SWIPE_MERCHANT_ID"],
      td_item: "contribution",
      td_currency: currency,
      td_description: "One-time contribution to Loomio",
      td_amount: @amount,
      td_user_data: @user.email
    }
  end
end
