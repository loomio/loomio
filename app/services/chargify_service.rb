class ChargifyService
  STANDARD_PLAN_URL = "http://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscribe/#{ENV['CHARGIFY_STANDARD_PLAN_KEY']}/#{ENV['CHARGIFY_STANDARD_PLAN_NAME']}"
  PLUS_PLAN_URL = "http://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscribe/#{ENV['CHARGIFY_PLUS_PLAN_KEY']}/#{ENV['CHARGIFY_PLUS_PLAN_NAME']}"

  def self.params_of(hash)
    "?"+hash.map{|k, v| "#{k}=#{CGI.escape(v)}"}.join('&')
  end

  def self.standard_plan_url(group)
    STANDARD_PLAN_URL + params_of(organization: group.name, reference: group.key)
  end

  def self.plus_plan_url(group)
    PLUS_PLAN_URL + params_of(organization: group.name, reference: group.key)
  end

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
