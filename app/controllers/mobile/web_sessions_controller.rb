class Mobile::WebSessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  rescue_from Mobile::AuthenticationService::Error, with: :render_ticket_error

  def create
    raise Mobile::AuthenticationService::Error.new("invalid_request") if request.query_string.present?
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless request.media_type == "application/x-www-form-urlencoded"

    ticket = params.require(:ticket).to_s
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless ticket.match?(/\Alm_ws_[A-Za-z0-9_-]{43}\z/)

    user = Mobile::AuthenticationService.consume_web_session_ticket!(ticket)
    sign_in(user)
    response.headers["Cache-Control"] = "no-store"
    response.headers["Referrer-Policy"] = "no-referrer"
    redirect_to dashboard_path, status: :see_other
  end

  private

  def render_ticket_error(error)
    response.headers["Cache-Control"] = "no-store"
    response.headers["Referrer-Policy"] = "no-referrer"
    render plain: I18n.t("mobile_auth.errors.#{error.code}", default: I18n.t("mobile_auth.errors.invalid_request")), status: error.status
  end
end
