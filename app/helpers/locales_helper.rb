require 'http_accept_language'

module LocalesHelper

  def selected_locale
    (params[:locale] || current_user_or_visitor.selected_locale).try(:to_s)
  end

  def locale_selected?
    params.has_key?(:locale) || current_user_or_visitor.locale.present?
  end

  def detected_locale(supported_locales = Translation.locales)
    (browser_accepted_locales & supported_locales).first
  end

  def default_locale
    I18n.default_locale.to_s
  end

  def current_locale
    I18n.locale.to_s
  end

  def set_application_locale
    I18n.locale = best_locale
  end

  def best_locale
    if user_signed_in?
      best_available_locale
    else
      best_cachable_locale
    end
  end

  def best_available_locale
    selected_locale || detected_locale || default_locale
  end

  def best_cachable_locale
    selected_locale || default_locale
  end

  def locale_fallback(first, second = nil)
    first || second || default_locale
  end

  def browser_accepted_locales
    header = request.env['HTTP_ACCEPT_LANGUAGE']
    parser = HttpAcceptLanguage::Parser.new(header)
    parser.user_preferred_languages
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
