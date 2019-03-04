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
    render 'application/index', layout: false
  end

  def crowdfunding
    render layout: 'basic'
  end

  def ok
    head :ok
  end
end
