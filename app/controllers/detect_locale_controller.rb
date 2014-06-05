class DetectLocaleController < ActionController::Base
  layout false
  include LocalesHelper
  include CurrentUserHelper

  def show
    d = locale_fallback(detected_locale)
    if current_locale != d
      I18n.locale = d
      Measurement.increment('detect_locale.foreign')
    else
      Measurement.increment('detect_locale.default')
      head :ok
    end
  end


  private
  def current_locale
    locale = (supported_locales & [params[:current_locale]]).first

    if locale.present?
      locale.to_sym
    else
      default_locale
    end
  end
end
