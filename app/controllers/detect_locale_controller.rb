class DetectLocaleController < ActionController::Base
  include LocalesHelper
  include CurrentUserHelper

  def show
    if detected_locale.present? and 
      (detected_locale != params[:current_locale])
      I18n.locale = best_available_locale
    else
      head :ok
    end
  end
end
