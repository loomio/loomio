class ApplicationController < ActionController::Base
  include LocalesHelper
  include ApplicationHelper
  include AngularHelper
  include ProtectedFromForgery
  include LoadAndAuthorize
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

  def respond_with_error(message, status: :bad_request)
    render 'application/display_error', locals: { message: t(message) }, status: status
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params)
  end

  def dashboard_or_root_path
    current_user.is_logged_in? ? dashboard_path : root_path
  end

  def store_previous_location
    session[:user_return_to] ||= URI.unescape(params.fetch(:return_to, '')).chomp('/') || request.env['HTTP_REFERER']
  end

  def clear_stored_location
    session[:user_return_to] = nil
  end

  def after_sign_in_path_for(resource)
    resource.update_attribute(:detected_locale, locales_from_browser_detection.first)
    user_return_path.tap { clear_stored_location }
  end

  def user_return_path
    if invalid_return_urls.include? session[:user_return_to]
      case current_user_groups.count
      when 0 then explore_path
      when 1 then group_path(current_user_groups.first)
      else        dashboard_or_root_path
      end
    else
      session[:user_return_to]
    end
  end

  def current_user_groups
    @current_user_groups ||= current_user.groups
  end

  def user_signed_in?
    current_user.is_logged_in?
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone_city, &block)
  end

  def invalid_return_urls
    [nil, root_url, new_user_password_url, '']
  end

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:email, :name, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.permit(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
  end
end
