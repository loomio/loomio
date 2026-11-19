module RequestIp
  extend ActiveSupport::Concern

  included do
    around_action :with_request_ip
  end

  private

  def with_request_ip
    # Use the same trusted Cloudflare/client-IP policy as IP bans and throttles.
    Current.set(request_ip: Rack::Attack::Request.new(request.env).remote_ip) { yield }
  end
end
