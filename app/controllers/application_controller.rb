class ApplicationController < ActionController::Base
  include LocalesHelper
  include ReadableUnguessableUrlsHelper
  protect_from_forgery

  before_filter :set_locale
  before_filter :initialize_search_form
  around_filter :user_time_zone, if: :current_user
  helper :analytics_data
  helper_method :current_user_or_visitor

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      flash[:error] = t("error.access_denied")
      redirect_to root_url
    else
      store_location
      authenticate_user!
    end
  end

  protected

  def current_user_or_visitor
    current_user || LoggedOutUser.new
  end

  def store_location
    session['user_return_to'] = request.original_url
  end

  def clear_stored_location
    session['user_return_to'] = nil
  end

  def after_sign_in_path_for(resource)
    path = session['user_return_to'] || root_path
    clear_stored_location
    path
  end

  def initialize_search_form
    @search_form = SearchForm.new(current_user)
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.time_zone_city, &block)
  end


  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :name, :password, :password_confirmation, :language_preference)
    end

    devise_parameter_sanitizer.for(:sign_in) do |u|
      u.permit(:email, :password, :language_preference, :remember_me)
    end
  end
end
