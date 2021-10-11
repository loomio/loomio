class API::V1::RestfulController < API::V1::SnorlaxBase
  include ::LocalesHelper
  include ::ProtectedFromForgery
  include ::LoadAndAuthorize
  include ::CurrentUserHelper
  include ::SentryHelper
  include ::PendingActionsHelper

  before_action :handle_pending_actions
  around_action :use_preferred_locale       # LocalesHelper
  before_action :set_paper_trail_whodunnit  # gem 'paper_trail'
  before_action :set_sentry_context          # SentryHelper
  before_action :deny_spam_users            # CurrentUserHelper

  private
  def require_current_user
    unless current_user && current_user.is_logged_in?
      render(json: {error: 'you gotta be signed in'}, root: false, status: 401)
    end
  end
end
