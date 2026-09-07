class Api::V1::Mobile::RelayAuthorizationsController < Api::V1::Mobile::BaseController
  skip_before_action :authenticate_mobile_access_token!, only: :verify
  before_action -> { require_mobile_scope!("relay:register") }, only: :create

  def create
    issued = Mobile::RelayAuthorizationService.issue!(device: current_mobile_device)
    no_store!
    render json: issued, status: :created
  end

  def verify
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless request.media_type == "application/json"
    raise Mobile::AuthenticationService::Error.new("invalid_request") if request.raw_post.bytesize > 1_024
    body = JSON.parse(request.raw_post)
    unless body.is_a?(Hash) && body.keys == [ "authorization" ]
      raise Mobile::AuthenticationService::Error.new("invalid_request")
    end

    raw = body["authorization"].to_s
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless raw.match?(/\Alm_ra_[A-Za-z0-9_-]{43}\z/)

    no_store!
    render json: Mobile::RelayAuthorizationService.verify!(raw)
  rescue JSON::ParserError
    raise Mobile::AuthenticationService::Error.new("invalid_request")
  end

  private

  def no_store!
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"
  end
end
