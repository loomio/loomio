class BaseController < ApplicationController
  include AutodetectTimeZone
  include OmniauthAuthenticationHelper

  before_filter :authenticate_user!

  before_filter :check_for_omniauth_authentication,
                :check_for_invitation,
                :ensure_user_name_present,
                :set_time_zone_from_javascript, unless: :ajax_request?

  helper_method :time_zone

  protected

  def ajax_request?
    request.xhr? or not user_signed_in?
  end

  def ensure_user_name_present
    unless current_user.name.present?
      redirect_to profile_path, alert: "Please enter your name to continue"
    end
  end

  def check_for_invitation
    if session[:invitation_token]
      redirect_to invitation_path(session[:invitation_token])
    end
  end
end
