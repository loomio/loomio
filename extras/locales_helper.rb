module LocalesHelper
  def selected_locale
    (params[:locale] || current_user_or_visitor.selected_locale).try(:to_sym)
  end

  def locale_selected?
    params.has_key?(:locale) || current_user_or_visitor.locale.present?
  end

  def detected_locale(supported_locales = AppTranslation.locales)
    (browser_accepted_locales & supported_locales).first
  end

  def default_locale
    I18n.default_locale.to_sym
  end

  def current_locale
    I18n.locale
  end

  def set_application_locale
    if user_signed_in?
      I18n.locale = best_available_locale
    else
      I18n.locale = best_cachabale_locale
    end
  end

  def best_available_locale
    selected_locale || detected_locale || default_locale
  end

  def best_cachabale_locale
    selected_locale || default_locale
  end

  def best_locale(first, second = nil)
    first || second || default_locale
  end

  def suggest_detected_locale?
    !locale_selected? and
    detected_locale.present? and
    (detected_locale != default_locale)
  end

  def browser_accepted_locales
    http_accept_language = request.env['HTTP_ACCEPT_LANGUAGE']
    return [] if http_accept_language.blank?
    langs = http_accept_language.scan(/([a-zA-Z]{2,4})(?:-[a-zA-Z]{2})?(?:;q=(1|0?\.[0-9]{1,3}))?/).map do |pair|
      lang, q = pair
      [lang.to_sym, (q || '1').to_f]
    end
    langs.sort_by { |lang, q| q }.map { |lang, q| lang }.reverse
  end

  def save_detected_locale(user)
    user.update_attribute(:detected_locale, detected_locale)
  end

  def save_selected_locale
    locale = params[:locale]
    if AppTranslation.permitted_locale?(locale)
      current_user.update_attribute(:selected_locale, locale)
    end
  end
end
