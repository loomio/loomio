class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    request.env["HTTP_REFERER"] = root_url if request.env["HTTP_REFERER"].nil?
    flash[:error] = "Access denied."
    redirect_to :back
  end
end
