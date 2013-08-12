class ApplicationController < ActionController::Base
  include LocalesHelper
  protect_from_forgery

  before_filter :set_locale
  before_filter :initialize_search_form

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
end
