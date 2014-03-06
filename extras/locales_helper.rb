module LocalesHelper
  def selected_locale
    params[:locale] || current_user_or_visitor.selected_locale
  end

  def detected_locale
    (browser_accepted_locales & Translation.locales).first
  end

  def default_locale
    I18n.default_locale.to_s
  end

  def current_locale
    I18n.locale
  end

  def locale_selected?
    params.has_key?(:locale) || current_user_or_visitor.locale.present?
  end

  def suggest_detected_locale?
    selected_locale.nil? and
    detected_locale.present? and
    (detected_locale != default_locale)
  end

  def set_application_locale
    I18n.locale = best_available_locale
  end

  def best_available_locale
    selected_locale || detected_locale || default_locale
  end

  def save_detected_locale
    current_user.update_attribute(:detected_locale, detected_locale)
  end

  def save_selected_locale_if_possible
    locale = params[:locale]
    if locale.present? and user_signed_in? and valid_locale?(locale)
      current_user.update_attribute(:selected_locale, locale)
    end
  end

  def browser_accepted_locales
    http_accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    return [] if http_accept_language.blank?
    langs = http_accept_language.scan(/([a-zA-Z]{2,4})(?:-[a-zA-Z]{2})?(?:;q=(1|0?\.[0-9]{1,3}))?/).map do |pair|
      lang, q = pair
      [lang, (q || '1').to_f]
    end
    langs.sort_by { |lang, q| q }.map { |lang, q| lang }.reverse
  end

  def valid_locale?(locale)
    Translation.locales.include? locale
  end

  def experimental_locale?(locale)
    Translation.experimental_locales.include? locale
  end
end
