class ApplicationController < ActionController::Base
  include LocalesHelper
  include ApplicationHelper
  include AngularHelper
  include ProtectedFromForgery
  include LoadAndAuthorize
  include PendingActionsHelper
  include CurrentUserHelper

  helper :analytics_data
  helper :locales
  helper_method :current_user
  helper_method :dashboard_or_root_path

  before_filter :set_application_locale
  around_filter :user_time_zone, if: :user_signed_in?

  # intercom
  skip_after_filter :intercom_rails_auto_include

  rescue_from(ActionView::MissingTemplate)  { |exception| raise exception unless %w[txt text gif png].include?(params[:format]) }
  rescue_from(ActiveRecord::RecordNotFound) { respond_with_error :"error.not_found", status: :not_found }
  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      flash[:error] = t("error.access_denied")
      redirect_to dashboard_path
    else
      authenticate_user!
    end
  end

  def gone
    head :gone
  end

  def browser_not_supported
    render layout: false
  end

  protected

  def sign_in(user_or_resource, user = nil)
    super && handle_pending_actions(user || user_or_resource)
  end

  def respond_with_error(message, status: :bad_request)
    render 'application/display_error', locals: { message: t(message) }, status: status
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
