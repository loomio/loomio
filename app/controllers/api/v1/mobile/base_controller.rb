class Api::V1::Mobile::BaseController < ActionController::API
  before_action :authenticate_mobile_access_token!

  rescue_from Mobile::AuthenticationService::Error, with: :render_mobile_error
  rescue_from Mobile::RelayService::Error, with: :render_relay_error

  private

  attr_reader :current_mobile_access_token

  def authenticate_mobile_access_token!
    raw = request.authorization.to_s[/\ABearer (lm_at_[A-Za-z0-9_-]+)\z/, 1]
    @current_mobile_access_token = Mobile::AuthenticationService.authenticate_access_token(raw)
  end

  def current_mobile_device
    current_mobile_access_token.mobile_device
  end

  def require_mobile_scope!(scope)
    return if current_mobile_access_token.allows_scope?(scope)

    raise Mobile::AuthenticationService::Error.new("insufficient_scope", status: :forbidden)
  end

  def render_mobile_error(error)
    response.headers["Cache-Control"] = "no-store"
    render json: {
      error: error.code,
      error_description: I18n.t("mobile_auth.errors.#{error.code}", default: I18n.t("mobile_auth.errors.invalid_request"))
    }, status: error.status
  end

  def render_relay_error(_error)
    render_mobile_error(
      Mobile::AuthenticationService::Error.new("temporarily_unavailable", status: :service_unavailable)
    )
  end
end
