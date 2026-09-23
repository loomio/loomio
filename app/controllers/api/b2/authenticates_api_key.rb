module Api::B2::AuthenticatesApiKey
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token
    prepend_before_action :authenticate_api_key!
  end

  def authenticate_api_key!
    raise CanCan::AccessDenied unless current_user
  end

  def current_user
    @current_user ||= User.active.find_by(api_key: bearer_token.presence || request.request_parameters[:api_key])
  end

  private

  def bearer_token
    request.authorization.to_s[/\ABearer (.+)\z/, 1].to_s
  end
end
