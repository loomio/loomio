class API::B1::BaseController < API::V1::SnorlaxBase
  # include ForceSslHelper
  # include LoadAndAuthorize
  # include SentryHelper
  #
  # before_action :set_paper_trail_whodunnit  # gem 'paper_trail'
  before_action :authenticate_api_key!
  # # before_action :set_sentry_context         # SentryHelper
  #
  def authenticate_api_key!
    @current_integration = Integration.find_by(token: params[:api_key])
    raise CanCan::AccessDenied unless @current_integration
  end

  def current_user
    @current_integration.actor
  end
end
