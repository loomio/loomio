class Api::V1::Mobile::ConfigController < ActionController::API
  def show
    response.headers["Cache-Control"] = "no-store"
    origin = request.base_url
    render json: {
      protocol_version: Mobile::AuthenticationService::PROTOCOL_VERSION,
      issuer: origin,
      authorization_endpoint: "#{origin}/mobile/authorize",
      token_endpoint: "#{origin}/api/v1/mobile/token",
      web_session_ticket_endpoint: "#{origin}/api/v1/mobile/web-session-tickets",
      web_session_bootstrap_endpoint: "#{origin}/mobile/web-session",
      relay_authorization_endpoint: "#{origin}/api/v1/mobile/relay-authorizations",
      push_registration_endpoint: "#{origin}/api/v1/mobile/push-registration",
      activity_endpoint: "#{origin}/api/v1/mobile/activity",
      device_endpoint: "#{origin}/api/v1/mobile/device"
    }
  end
end
