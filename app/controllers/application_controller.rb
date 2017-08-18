class ApplicationController < ActionController::Base
  include LocalesHelper
  include AngularHelper
  include ApplicationHelper
  include ProtectedFromForgery
  include ErrorRescueHelper
  include CurrentUserHelper

  before_filter :initial_payload, only: :index
  before_filter :set_application_locale
  before_filter :set_invitation_token
  around_filter :user_time_zone
  after_filter  :save_detected_locale

  helper_method :current_user
  helper_method :client_asset_path
  helper_method :detectable_locales

  layout false, only: :index

  # this boots the angular app
  def index
  end

  protected

  def initial_payload
    @payload ||= InitialPayload.new(current_user).payload.merge(
      flash:           flash.to_h,
      pendingIdentity: serialized_pending_identity
    )
  end

  def user_time_zone(&block)
    Time.use_zone(TimeZoneToCity.convert(current_user.time_zone), &block)
  end
end
