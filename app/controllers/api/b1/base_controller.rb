class API::B1::BaseController < API::V1::SnorlaxBase
  before_action :authenticate_api_key!
  include ::LoadAndAuthorize

  def authenticate_api_key!
    raise CanCan::AccessDenied unless current_webhook
  end

  def current_user
    current_webhook.actor
  end

  def current_webhook
    @current_webhook ||= Webhook.find_by(token: params[:api_key])
  end

  private
  def permitted_params
    jarams = params.dup
    if jarams[:api_key]
      jarams.delete(:api_key)
      jarams = ActionController::Parameters.new({resource_name => jarams})
    end
    @permitted_params ||= PermittedParams.new(jarams)
  end
end
