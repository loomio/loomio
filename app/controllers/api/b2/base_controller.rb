class Api::B2::BaseController < Api::V1::SnorlaxBase
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key!
  include ::LoadAndAuthorize

  def authenticate_api_key!
    raise CanCan::AccessDenied unless current_user
  end

  def current_user
    @current_user ||= User.active.find_by(api_key: params[:api_key])
  end

  private
  def permitted_params
    jarams = params.dup
    if jarams[:api_key]
      jarams.delete(:api_key)
      jarams.delete(:format)
      jarams.delete(:discussion)
      jarams.delete(:poll)
      jarams = ActionController::Parameters.new({resource_name => jarams})
    end

    @permitted_params ||= PermittedParams.new(jarams)
  end
end
