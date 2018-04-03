class ApplicationController < ActionController::Base
  include LocalesHelper
  include AngularHelper
  include ProtectedFromForgery
  include ErrorRescueHelper
  include CurrentUserHelper
  include ForceSslHelper
  include SentryRavenHelper

  around_action :process_time_zone
  around_action :use_preferred_locale   # LocalesHelper
  before_action :set_invitation_token   # CurrentUserHelper
  before_action :set_last_seen_at       # CurrentUserHelper
  before_action :set_raven_context

  helper_method :current_user
  helper_method :current_version
  helper_method :client_asset_path
  helper_method :bundle_asset_path
  helper_method :supported_locales

  def index
    render 'application/index', layout: false
  end

  def ok
    head :ok
  end

  protected

  def process_time_zone(&block)
    Time.use_zone(TimeZoneToCity.convert(current_user.time_zone.to_s), &block)
  end
end
