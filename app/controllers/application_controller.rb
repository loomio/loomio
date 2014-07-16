class ApplicationController < ActionController::Base
  include LocalesHelper
  include CurrentUserHelper
  include ReadableUnguessableUrlsHelper
  include IntercomHelper

  protect_from_forgery

  helper :analytics_data
  helper :locales
  helper_method :current_user_or_visitor
  helper_method :dashboard_or_root_path
  helper_method :subdomain

  before_filter :set_application_locale
  around_filter :user_time_zone, if: :user_signed_in?

  after_filter :increment_measurement

  # intercom
  skip_after_filter :intercom_rails_auto_include

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      flash[:error] = t("error.access_denied")
      redirect_to dashboard_path
    else
      authenticate_user!
    end
  end

  protected
  def subdomain
    request.subdomain.gsub(/^www./, '')
  end

  def increment_measurement
    Measurement.increment(measurement_name)
  end

  def measurement_name
    "#{controller_name}.#{action_name}"
  end

  def default_url_options
    if params.has_key?(:locale)
      super.merge({locale: selected_locale})
    else
      super
    end
  end

  def dashboard_or_root_path
    if user_signed_in?
      dashboard_path
    else
      root_path
    end
  end

  def store_previous_location
    session['user_return_to'] = request.env['HTTP_REFERER'] if request.env['HTTP_REFERER'].present?
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
      dashboard_path
    else
      session['user_return_to']
    end
  end

  def invalid_return_urls
    [nil, new_user_password_url]
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone_city, &block)
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
