class Api::V1::Mobile::WebSessionTicketsController < Api::V1::Mobile::BaseController
  before_action -> { require_mobile_scope!("web_session:create") }

  def create
    ticket = Mobile::AuthenticationService.issue_web_session_ticket!(device: current_mobile_device)
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"
    render json: { ticket: ticket, expires_in: Mobile::AuthenticationService::WEB_SESSION_TICKET_TTL.to_i }
  end
end
