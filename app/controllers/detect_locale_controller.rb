class DetectLocaleController < ActionController::Base
  include LocalesHelper
  include CurrentUserHelper

  def show
    d = detected_locale(Translation.frontpage_locales)
    if d.present? and (current_locale != d)
      I18n.locale = d
    else
      head :ok
    end
  end

  private
  def current_locale
    locale = (Translation.locales & [params[:current_locale]]).first

    if locale.present?
      locale.to_sym
    else
      default_locale
    end
  end
end
