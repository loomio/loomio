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
    if user_signed_in?
      I18n.locale = best_logged_in_locale
    else
      I18n.locale = best_logged_out_locale
    end
  end

  # consider best_locale
  def best_logged_in_locale
    selected_locale || detected_locale || default_locale
  end

  # consider best_cachable_locale
  def best_logged_out_locale
    selected_locale || default_locale
  end

  # consider locale_fallback
  def best_locale(first, second = nil)
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
end
