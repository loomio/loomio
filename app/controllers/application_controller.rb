class ApplicationController < ActionController::Base
  include LocalesHelper
  include ApplicationHelper
  include AngularHelper
  include ProtectedFromForgery
  include LoadAndAuthorize
  include CurrentUserHelper

  helper :locales
  helper_method :current_user
  helper_method :dashboard_or_root_path

  before_filter :set_invitation_token
  before_filter :set_application_locale

  around_filter :user_time_zone, if: :user_signed_in?
  after_filter :save_detected_locale, if: :user_signed_in?

  rescue_from(ActionView::MissingTemplate)  { |exception| raise exception unless %w[txt text gif png].include?(params[:format]) }
  rescue_from(ActiveRecord::RecordNotFound) { respond_with_error message: :"error.not_found", status: 404 }
  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      flash[:error] = t("error.access_denied")
      redirect_to dashboard_path
    else
      authenticate_user!
    end
  end

  protected

  def respond_with_error(message: "", status: 400)
    @error_description ||= message
    render "errors/#{status}", layout: 'error', status: status
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params)
  end

  def dashboard_or_root_path
    current_user.is_logged_in? ? dashboard_path : root_path
  end

  def user_signed_in?
    current_user.is_logged_in?
  end

  def user_time_zone(&block)
    Time.use_zone(TimeZoneToCity.convert(current_user.time_zone), &block)
  end
end
