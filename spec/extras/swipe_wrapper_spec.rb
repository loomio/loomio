require "spec_helper"
require_relative "../../extras/swipe_wrapper"
describe SwipeWrapper do
  before do
    ENV["SWIPE_PAYMENT_URL"] = "http://swipe.com/payment"
    ENV["SWIPE_API_KEY"] = "123apikey"
    ENV["SWIPE_MERCHANT_ID"] = "123merchantid"
  end
  let(:current_user){stub(:email, :email => 'jim@bob.com')}

  context 'currency' do
    it 'returns chosen currency if in list' do
      wrapper = SwipeWrapper.new
      wrapper.currency = 'nzd'
      wrapper.currency.should == 'NZD'
    end

    it 'returns usd if currency unrecognised' do
      wrapper = SwipeWrapper.new
      wrapper.currency = 'notreal'
      wrapper.currency.should == 'USD'
    end
  end

  context 'get_transaction_identifier' do
    it 'posts to swipeHQ' do
      pending 'untestable'
      amount = 10
      currency = 'nzd'
      query_params = {
        api_key: ENV["SWIPE_API_KEY"],
        merchant_id: ENV["SWIPE_MERCHANT_ID"],
        td_item: "contribution",
        td_currency: "nzd",
        td_description: "One-time contribution to Loomio",
        td_amount: amount,
        td_user_data: current_user.email,
      }
      SwipeWrapper.should_receive(:post).with(ENV["SWIPE_PAYMENT_URL"], :query => query_params)
      wrapper = SwipeWrapper.new
      wrapper.stub(:parse_identifier_from_response)
      wrapper.create_tx_identifier_for(user: current_user, amount: amount, currency: currency)
    end

    it 'returns a transaction identifier' do
      pending "can't properly test this"
    end
  end
end
