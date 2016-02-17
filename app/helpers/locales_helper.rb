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

  def incomplete_locales
    rtl_locales - selectable_locales
  end

  def locale_name(locale)
    prefix = incomplete_locales.include?(locale) ? "incomplete: " : ""
    prefix + I18n.t(locale.to_sym, scope: :native_language_name)
  end

  def selected_locale
    params_selected_locale || user_selected_locale
  end

  # 1 of 2 places untrusted input can enter system
  def detected_locale
    first_detectable_locale browser_accepted_locales
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

  def locale_fallback(first, second = nil)
    first || second || default_locale
  end

  def save_detected_locale(user)
    user.update_attribute(:detected_locale, detected_locale)
  end

  def text_direction(object)
    locale = object.try(:locale).try(:to_sym)
    language_dir(locale)
  end

  def language_dir(locale)
    rtl_locales.include?(locale) ? 'RTL' : 'LTR'
  end

  # View helper methods for language selector dropdown

  def linked_language_options
    @linked_language_options ||= language_options_for selectable_locales, link_values: true
  end

  def language_options
    @language_options ||= language_options_for selectable_locales, nil, incomplete_locales
  end

  def angular_locales
    selectable_locales.map do |locale|
      {key: locale, name: locale_name(locale)}
    end
  end

  private

  def browser_accepted_locales
    header = request.env['HTTP_ACCEPT_LANGUAGE']
    parser = HttpAcceptLanguage::Parser.new(header)

    filter_locales(parser.user_preferred_languages, I18n.available_locales)
  end

  def best_locale
    selected_locale || detected_locale || default_locale
  end

  def params_selected_locale
    filter_locales(params[:locale], I18n.available_locales).first
  end

  def user_selected_locale
    first_selectable_locale (current_user || LoggedOutUser.new).selected_locale
  end

  def first_detectable_locale(locales)
    filter_locales(locales, detectable_locales).first
  end

  def first_selectable_locale(locales)
    filter_locales(locales, selectable_locales).first
  end

  def filter_locales(input_locales, valid_locales)
    Array(input_locales).map(&:to_sym) & Array(valid_locales).map(&:to_sym)
  end

  def language_options_for(*locales, link_values: false)
    locales.flatten.map do |locale|
      if locale.present?
        value = link_values ? url_for(locale: locale) : locale
        [locale_name(locale), value]
      else
        ['---------------------------------', 'disabled_option']
      end
    end
  end

end
