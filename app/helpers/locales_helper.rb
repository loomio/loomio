#require 'http_accept_language'

module LocalesHelper

  def process_locale
    I18n.locale = best_locale
    yield if block_given?
    save_detected_locale
  end

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
    I18n.locale = best_locale
  end

  def best_locale
    (Array(locales_from_param)             | # locale from request param
     Array(locales_from_user_preference)   | # locale from selected user preference
     Array(locales_from_browser_detection) | # locales from browser headers
     Array(locales_from_saved_browser_detection)   | # locale from selected user preference
     Array(I18n.default_locale)).compact.first
  end

  def save_detected_locale
    if current_user.is_logged_in? && locales_from_browser_detection.any?
      current_user.update_detected_locale(locales_from_browser_detection.first)
    end
  end

  private

  def locales_from_param
    filter_locales params[:locale], I18n.available_locales
  end

  def locales_from_user_preference
    return unless current_user&.is_logged_in?
    filter_locales(current_user.selected_locale, selectable_locales)
  end

  def locales_from_saved_browser_detection
    return unless current_user&.is_logged_in?
    filter_locales(current_user.detected_locale, selectable_locales)
  end

  def locales_from_browser_detection
    parser = HttpAcceptLanguage::Parser.new(request.env["HTTP_ACCEPT_LANGUAGE"])
    locales = parser.user_preferred_languages +
              parser.user_preferred_languages.map { |l| l.split('-').first } # to catch locales like fr-fr, or en-nz
    filter_locales(locales, detectable_locales)
  end

  def filter_locales(input_locales, valid_locales)
    (Array(input_locales).map(&:to_sym) & Array(valid_locales).map(&:to_sym)).compact.uniq
  end

end
