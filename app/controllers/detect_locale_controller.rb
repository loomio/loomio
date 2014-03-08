class DetectLocaleController < ActionController::Base
  include LocalesHelper
  include CurrentUserHelper

  def show
    if detected_locale.present? and params[:current_locale].present? and (detected_locale != params[:current_locale])
      I18n.locale = detected_locale
    else
      head :ok
    end
  end
end
