class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  rescue_from CanCan::AccessDenied do |exception|
    request.env["HTTP_REFERER"] = root_url if request.env["HTTP_REFERER"].nil?
    flash[:error] = t("error.access_denied")
    redirect_to :back
  end


  protected

  def set_locale
    if current_user
      if current_user.language_preference.blank?
        current_user.language_preference = extract_locale_from_accept_language_header
      end
      I18n.locale = current_user.language_preference
    else
      I18n.locale = extract_locale_from_accept_language_header
    end
    I18n.locale = params[:locale] if params[:locale].present?
  end

  def extract_locale_from_accept_language_header
    browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /^[a-z]{2}/).try(:first).try(:to_s)
    available_locales = %w{en es el}
    if available_locales.include? browser_locale
      browser_locale
    else
      I18n.default_locale
    end
  end
end
