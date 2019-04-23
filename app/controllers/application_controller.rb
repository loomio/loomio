class ApplicationController < ActionController::Base
  include LocalesHelper
  include AngularHelper
  include ProtectedFromForgery
  include ErrorRescueHelper
  include CurrentUserHelper
  include ForceSslHelper
  include SentryRavenHelper
  include PrettyUrlHelper

  around_action :process_time_zone          # LocalesHelper
  around_action :use_preferred_locale       # LocalesHelper
  before_action :set_last_seen_at           # CurrentUserHelper
  before_action :handle_pending_memberships # PendingActionsHelper
  before_action :set_raven_context

  helper_method :current_user
  helper_method :current_version
  helper_method :client_asset_path
  helper_method :bundle_asset_path
  helper_method :supported_locales

  # this boots the angular app
  def index
    expires_now
    prevent_caching

    if current_user.is_logged_in? && current_user.experiences['vue_client']
      render file: 'public/client/vue/index.html', layout: false
    else
      render 'application/index', layout: false
    end
  end

  def crowdfunding
    render layout: 'basic'
  end

  def ok
    head :ok
  end

  def redirect_to(path)
    if !Rails.env.production? && ENV['USE_VUE']
      super "http://localhost:8080#{URI(path).path}"
    else
      super
    end
  end

  protected
  def prevent_caching
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate' # HTTP 1.1.
    response.headers['Pragma'] = 'no-cache' # HTTP 1.0.
    response.headers['Expires'] = '0' # Proxies.
  end
end
