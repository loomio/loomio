module LocalesHelper
  def use_preferred_locale
    I18n.locale = preferred_locale
    yield if block_given?
    save_detected_locale
  end

  def preferred_locale
    strict_filter(params[:locale]) ||
    fuzzy_filter(user_selected_locale) ||
    fuzzy_filter(browser_detected_locales) ||
    fuzzy_filter(user_detected_locale) ||
    I18n.default_locale
  end

  def supported_locales
    YAML.load_file(Rails.root.join('config', 'locales.yml'))["supported_locales"]
  end

  def angular_locales
    supported_locales.map do |locale|
      { key: locale, name: I18n.t(locale.to_sym, scope: :native_language_name) }
    end
  end

  def save_detected_locale
    if current_user.is_logged_in? && browser_detected_locales.any?
      current_user.update_detected_locale(browser_detected_locales.first)
    end
  end

  private

  def normalize(locale)
    locale.to_s.sub('-','_')
  end

  def strict_filter(locales)
    Array(locales).compact.select do |locale|
      supported_locales.select{|supported_locale| supported_locale == normalize(locale)}.first
    end.first
  end

  def fuzzy_filter(locales)
    Array(locales).compact.map do |locale|
      [normalize(locale),
       strip_dialect(locale),
       fallback_for(locale)].select do |version|
        supported_locales.include? version
      end.first
    end.compact.first
  end

  def strip_dialect(locale)
    locale.split('_').first
  end

  def fallback_for(locale)
    fallbacks[locale] || fallbacks[strip_dialect(locale)]
  end

  def fallbacks
    YAML.load_file(Rails.root.join('config', 'locales.yml'))["fallbacks"]
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
