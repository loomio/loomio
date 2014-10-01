class DetectLocaleController < ActionController::Base
  layout false
  include LocalesHelper
  include CurrentUserHelper

  def show
    d = locale_fallback(detected_locale)
    if locale_fallback(selected_locale) != d
      I18n.locale = d
      Measurement.increment('detect_locale.foreign')
    else
      Measurement.increment('detect_locale.default')
      head :ok
    end
  end

end
