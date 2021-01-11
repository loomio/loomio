class API::B1::BaseController < API::V1::SnorlaxBase
  rescue_from(CanCan::AccessDenied)                    { |e| respond_with_standard_error e, 403 }
  rescue_from(ActionController::UnpermittedParameters) { |e| respond_with_standard_error e, 400 }
  rescue_from(ActionController::ParameterMissing)      { |e| respond_with_standard_error e, 400 }
  rescue_from(ActiveRecord::RecordNotFound)            { |e| respond_with_standard_error e, 404 }
  #
  # include ForceSslHelper
  # include LoadAndAuthorize
  # include SentryHelper
  #
  # before_action :set_paper_trail_whodunnit  # gem 'paper_trail'
  before_action :authenticate_api_key!
  # # before_action :set_sentry_context         # SentryHelper
  #
  def authenticate_api_key!
    integration = Integration.find_by(token: params[:api_key])
    raise CanCan::AccessDenied unless integration
  end
end
