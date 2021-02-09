class API::B1::BaseController < API::V1::SnorlaxBase
  before_action :authenticate_api_key!
  include ::LoadAndAuthorize

  def authenticate_api_key!
    raise CanCan::AccessDenied unless Webhook.where(token: params[:api_key]).exists?
  end

  def current_user
    current_webhook.actor
  end

  def current_webhook
    Webhook.find_by(token: params[:api_key])
  end
end
