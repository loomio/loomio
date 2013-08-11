class ApplicationController < ActionController::Base
  include LocalesHelper
  protect_from_forgery

  rescue_from Exception do |exception|
    render_raincheck_error(exception)
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      request.env["HTTP_REFERER"] = root_url if request.env["HTTP_REFERER"].nil?
      flash[:error] = t("error.access_denied")
      redirect_to :back
    else
      store_location
      authenticate_user!
    end
  end

  before_filter :set_locale
  before_filter :initialize_search_form

  protected

  def store_location
    session[:return_to] = request.original_url
  end

  def clear_stored_location
    session[:return_to] = nil
  end

  def after_sign_in_path_for(resource)
    path = session[:return_to] || root_path
    clear_stored_location
    path
  end

  def initialize_search_form
    @search_form = SearchForm.new(current_user)
  end

  def render_raincheck_error(exception)
    if request.xhr?
      raise exception
    else
      @error_raincheck = ErrorRaincheck.new({action: action_name, controller: controller_name})
      respond_to do |format|
        format.html { render "error_rainchecks/error_page" }
        format.all  { render :nothing => true, :status => 500 }
      end
    end
  end
end
