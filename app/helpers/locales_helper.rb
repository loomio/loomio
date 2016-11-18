#require 'http_accept_language'

module LocalesHelper
  def selectable_locales
    Loomio::I18n::SELECTABLE_LOCALES
  end

  def detectable_locales
    Loomio::I18n::DETECTABLE_LOCALES
  end

  def rtl_locales
    Loomio::I18n::RTL_LOCALES
  end

  def angular_locales
    selectable_locales.map do |locale|
      { key: locale, name: I18n.t(locale.to_sym, scope: :native_language_name) }
    end
  end

  def set_application_locale
    I18n.locale = (locale_from_param              | # locale from request param
                   locale_from_user_preference    | # locale from selected user preference
                   locales_from_browser_detection | # locales from browser headers
                   I18n.default_locale).compact.first
  end

  private

  def locale_from_param
    filter_locales params[:locale], I18n.available_locales
  end

  def locale_from_user_preference
    return unless current_user&.is_logged_in?
    filter_locales(current_user.selected_locale, selectable_locales)
  end

  def locale_from_browser_detection
    parser = HttpAcceptLanguage::Parser.new(request.env["HTTP_ACCEPT_LANGUAGE"])
    filter_locales(parser.user_preferred_languages, detectable_locales)
  end

  def filter_locales(input_locales, valid_locales)
    Array(input_locales).map(&:to_sym) & Array(valid_locales).map(&:to_sym)
  end

end
