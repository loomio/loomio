class ApplicationController < ActionController::Base
  include LocalesHelper
  include AngularHelper
  include ProtectedFromForgery
  include ErrorRescueHelper
  include CurrentUserHelper
  include ForceSslHelper

  around_action :process_time_zone
  around_action :use_preferred_locale   # LocalesHelper
  before_action :set_invitation_token   # CurrentUserHelper
  before_action :set_last_seen_at       # CurrentUserHelper

  helper_method :current_user
  helper_method :client_asset_path
  helper_method :supported_locales

  # this boots the angular app
  def index
    initial_payload
    render 'application/index', layout: false
  end

  def ok
    head :ok
  end

  protected

  def initial_payload
    @payload ||= InitialPayload.new(current_user).payload.merge(
      flash:           flash.to_h,
      pendingIdentity: serialized_pending_identity
    )
  end

  def process_time_zone(&block)
    Time.use_zone(TimeZoneToCity.convert(current_user.time_zone.to_s), &block)
  end

  def hosted_by_loomio?
    false # overridden with loomio_org_plugin
  end
  helper_method :hosted_by_loomio?
end
