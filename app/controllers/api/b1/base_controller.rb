class API::B1::BaseController < API::V1::SnorlaxBase
  before_action :authenticate_api_key!

  def authenticate_api_key!
    raise CanCan::AccessDenied unless Webhook.where(token: params[:api_key]).exists?
  end

  def current_user
    Webhook.find_by(token: params[:api_key]).actor
  end
end
