class WebPushSubscriptionSerializer < ApplicationSerializer
  attributes :id, :endpoint, :created_at
  
  def endpoint
    # Only show a preview of the endpoint for security
    object.endpoint[0..50] + '...'
  end
end
