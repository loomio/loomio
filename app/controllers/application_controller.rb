class ApplicationController < ActionController::Base
  include LocalesHelper
  include AngularHelper
  include ApplicationHelper
  include ProtectedFromForgery
  include ErrorRescueHelper
  include CurrentUserHelper

  before_filter :initial_payload, only: :index
  around_filter :process_time_zone
  around_filter :process_locale         # LocalesHelper
  before_filter :set_invitation_token   # CurrentUserHelper

  helper_method :current_user
  helper_method :client_asset_path
  helper_method :detectable_locales

  # this boots the angular app
  layout false, only: :index
  def index
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
end
