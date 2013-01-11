class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    request.env["HTTP_REFERER"] = root_url if request.env["HTTP_REFERER"].nil?
    flash[:error] = "Access denied."
    redirect_to :back
  end

  def after_sign_in_path_for(resource)
    path = session[:return_to] || root_path
    clear_stored_location
    path
  end

  private

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_stored_location
    session[:return_to] = nil
  end
end
