class DetectLocaleController < ActionController::Base
  include LocalesHelper

  def show
    if suggest_detected_locale?
      I18n.locale = best_available_locale
    else
      head :ok
    end
  end
end
