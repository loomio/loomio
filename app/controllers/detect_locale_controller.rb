class DetectLocaleController < ActionController::Base
  include LocalesHelper
  include CurrentUserHelper

  def show
    if detected_locale.present? and (current_locale != detected_locale)
      I18n.locale = detected_locale
    else
      head :ok
    end
  end

  private
  def current_locale
    params[:current_locale].to_sym
  end
end
