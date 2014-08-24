require 'http_accept_language'

module LocalesHelper

  LOCALE_STRINGS          = Loomio::I18n::LANGUAGES.values.map(&:to_s)
  LOCALE_FALLBACK_STRINGS = Loomio::I18n::LOCALE_FALLBACKS.keys.map(&:to_s)

  def locale_name(locale)
    locale = fetch_fallback_locale(locale) if is_fallback_locale?(locale)

    Loomio::I18n::LANGUAGES.key(locale.to_sym)
  end

  def fetch_fallback_locale(locale)
    Loomio::I18n::LOCALE_FALLBACKS[locale.to_sym]
  end

  def is_fallback_locale?(locale)
    LOCALE_FALLBACK_STRINGS.include? locale.to_s
  end

  def supported_locale_strings
    LOCALE_STRINGS + LOCALE_FALLBACK_STRINGS + Loomio::I18n::EXPERIMENTAL_LOCALE_STRINGS
  end

  def valid_locale?(locale)
    return false if locale.blank?
    supported_locale_strings.include? locale.to_s
  end

  def selected_locale
    legal_selected_param || current_user_or_visitor.selected_locale  #string
  end

  def legal_selected_param
    if supported_locale_strings.include? params[:locale]
      params[:locale]
    else
      nil
    end
  end

  def locale_selected?
    params.has_key?(:locale) || current_user_or_visitor.locale.present?
  end

  def detected_locale
    (browser_accepted_locale_strings & supported_locale_strings).first.try(:to_sym)
  end

  def default_locale
    I18n.default_locale
  end

  def current_locale
    I18n.locale
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
      #   str              sym                 sym
  end

  def best_cachable_locale
    selected_locale || default_locale
  end

  def locale_fallback(first, second = nil)
    first || second || default_locale
  end

  def browser_accepted_locale_strings
    header = request.env['HTTP_ACCEPT_LANGUAGE']
    parser = HttpAcceptLanguage::Parser.new(header)
    parser.user_preferred_languages
  end

  def save_detected_locale(user)
    user.update_attribute(:detected_locale, detected_locale)
  end


  # methods for language selector dropdown

  def language_options_array
    options = []
    Loomio::I18n::LANGUAGES.each_pair do |language, locale|
      options << [language, current_path_with_locale(locale)]
    end
    options
  end

  def selected_language_option
    current_path_with_locale(current_locale)
  end

  def current_path_with_locale(locale)
    url_for(locale: locale)
  end
end
