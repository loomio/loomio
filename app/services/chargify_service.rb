class ChargifyService
  CHARGIFY_APP_NAME = Rails.application.secrets.chargify_app_name
  CHARGIFY_STANDARD_PLAN_KEY = Rails.application.secrets.chargify_standard_plan_key
  CHARGIFY_STANDARD_PLAN_NAME = Rails.application.secrets.chargify_standard_plan_name
  CHARGIFY_PLUS_PLAN_KEY = Rails.application.secrets.chargify_plus_plan_key
  CHARGIFY_PLUS_PLAN_NAME = Rails.application.secrets.chargify_plus_plan_name

  STANDARD_PLAN_URL = "http://#{CHARGIFY_APP_NAME}.chargify.com/subscribe/#{CHARGIFY_STANDARD_PLAN_KEY}/#{CHARGIFY_STANDARD_PLAN_NAME}"
  PLUS_PLAN_URL = "http://#{CHARGIFY_APP_NAME}.chargify.com/subscribe/#{CHARGIFY_PLUS_PLAN_KEY}/#{CHARGIFY_PLUS_PLAN_NAME}"

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
    "http://#{Rails.application.secrets.chargify_app_name}.chargify.com/subscriptions/#{@subscription_id}.json"
  end

  def basic_auth
    {
      username: Rails.application.secrets.chargify_api_key,
      password: :x # that's Mister X to you
    }
  end
end
