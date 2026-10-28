class Api::Server0::BaseController < Api::V1::SnorlaxBase
  skip_before_action :verify_authenticity_token
  prepend_before_action :authenticate_api_key!

  rescue_from(ServerMembershipService::InvalidParameters) { |error| respond_with_standard_error(error, 400) }
  rescue_from(Subscription::NotActive) { |error| respond_with_standard_error(error, 403) }

  private

  # Server credentials authorize these operations independently of browser
  # sessions, user API keys, and the memberships of any individual account.
  # Boot rejects short keys; the length check here also keeps an unset key closed.
  def authenticate_api_key!
    api_key = ServerApiKey.value
    token = request.authorization.to_s[/\ABearer (.+)\z/, 1].to_s
    raise CanCan::AccessDenied unless api_key.length >= ServerApiKey::LENGTH_MIN &&
      ActiveSupport::SecurityUtils.secure_compare(token, api_key)
  end
end
