class ChargifyService

  def initialize(subscription_id)
    @subscription_id = subscription_id
  end

  def fetch!
    subscription_from_chargify :get
  end

  def cancel!
    subscription_from_chargify :delete
  end

  def change_plan!(product_handle)
    subscription_from_chargify :put, { subscription: { product_handle: product_handle } }
  end

  private

  def subscription_from_chargify(action, payload = {})
    json = JSON.parse HTTParty.send(action, chargify_api_endpoint, body: payload, basic_auth: basic_auth).body
    json['subscription'] if json.present?
  end

  def chargify_api_endpoint
    "http://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{@subscription_id}.json"
  end

  def basic_auth
    {
      username: ENV['CHARGIFY_API_KEY'],
      password: :x # that's Mister X to you
    }
  end
end
