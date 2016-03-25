class ApplicationController < ActionController::Base
  include LocalesHelper
  include ReadableUnguessableUrlsHelper
  include ApplicationHelper
  include AngularHelper
  include ProtectedFromForgery
  include LoadAndAuthorize

  helper :analytics_data
  helper :locales
  helper_method :current_user_or_visitor
  helper_method :dashboard_or_root_path

  before_filter :set_application_locale
  # around_filter :user_time_zone, if: :user_signed_in?

  # intercom
  skip_after_filter :intercom_rails_auto_include

  rescue_from ActionView::MissingTemplate do |exception|
    raise exception unless %w[txt text gif png].include?(params[:format])
  end

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      flash[:error] = t("error.access_denied")
      redirect_to dashboard_path
    else
      authenticate_user!
    end
  end

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t('error.not_found') }
  end

  def browser_not_supported
    render layout: false
  end

  protected
  def permitted_params
    @permitted_params ||= PermittedParams.new(params)
  end

  def dashboard_or_root_path
    if user_signed_in?
      dashboard_path
    else
      root_path
    end
  end

  def store_previous_location
    return_to = request.env['HTTP_REFERER']

    if params['return_to']
      return_to = URI.unescape(params['return_to']).chomp('/')
    end

    session['user_return_to'] = return_to unless return_to.blank?
  end

  def clear_stored_location
    session['user_return_to'] = nil
  end

  def after_sign_in_path_for(resource)
    save_detected_locale(resource)
    path = user_return_path
    clear_stored_location
    path
  end

  def user_return_path
    if invalid_return_urls.include? session['user_return_to']
      dashboard_or_root_path
    else
      session['user_return_to']
    end
  end

  def current_user_or_visitor
    user_signed_in? ? current_user : LoggedOutUser.new
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone_city, &block)
  end

  def invalid_return_urls
    [nil, root_url, new_user_password_url]
  end

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :name, :password, :password_confirmation)
    end

    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :remember_me)
    end
  end
end
