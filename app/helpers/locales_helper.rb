module LocalesHelper
  def process_time_zone(&block)
    Time.use_zone(TimeZoneToCity.convert(current_user.time_zone.to_s), &block)
  end

  def use_preferred_locale
    I18n.locale = preferred_locale
    yield if block_given?
    save_detected_locale
  end

  def preferred_locale
    # allow unsupported locales via params
    normalize(params[:locale]) ||
    first_supported_locale(user_selected_locale,
                           browser_detected_locales,
                           user_detected_locale)
  end

  def logged_out_preferred_locale
    normalize(params[:locale]) ||
    first_supported_locale(browser_detected_locales)
  end

  def supported_locales
    AppConfig.locales['supported']
  end

  def save_detected_locale(user = current_user)
    if user.is_logged_in? && browser_detected_locales.any?
      user.update_detected_locale(first_supported_locale browser_detected_locales)
    end
  end

  def first_supported_locale(*locales)
    Array(locales).flatten.compact.map do |locale|
      [normalize(locale),
       strip_dialect(locale),
       fallback_for(locale)].detect do |version|
        supported_locales.include? version
      end
    end.compact.first || I18n.default_locale
  end

  private

  def normalize(locale)
    return unless locale
    lang, dialect = locale.to_s.sub('-', '_').split('_')
    [lang&.downcase, dialect&.upcase].compact.join('_')
  end


  def strip_dialect(locale)
    locale.to_s.split('_').first
  end

  def fallback_for(locale)
    fallbacks[locale] || fallbacks[strip_dialect(locale)]
  end

  def fallbacks
    AppConfig.locales['fallbacks']
  end

  def user_selected_locale
    return nil unless current_user&.is_logged_in?
    current_user.selected_locale
  end

  def user_detected_locale
    return unless current_user&.is_logged_in?
    current_user.detected_locale
  end

  def browser_detected_locales
    parser = HttpAcceptLanguage::Parser.new(request.env["HTTP_ACCEPT_LANGUAGE"])
    parser.user_preferred_languages.map {|locale| normalize locale }
  end
end
