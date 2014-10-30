require 'http_accept_language'

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

  def locale_name(locale)
    I18n.t(locale.to_sym, scope: :native_language_name)
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
    selectable_locales.map do |locale|
      [locale_name(locale), current_path_with_locale(locale)]
    end
  end

  def language_options
    supported_options = selectable_locales.map do |locale|
      [locale_name(locale), locale]
    end

    extra_options = (rtl_locales - selectable_locales).map do |locale|
      ["incomplete: " + locale_name(locale), locale]
    end

    supported_options +
    [['---------------------------------', 'disabled_option']] +
    extra_options
  end

  def selected_language_option
    current_path_with_locale(current_locale)
  end

  def current_path_with_locale(locale)
    url_for(locale: locale)
  end


  private

  def all_locale_strings
    I18n.available_locales.map &:to_s
  end

  def browser_accepted_locales
    header = request.env['HTTP_ACCEPT_LANGUAGE']
    parser = HttpAcceptLanguage::Parser.new(header)

    filter_locales(parser.user_preferred_languages, all_locale_strings)
  end

  def best_locale
    selected_locale || detected_locale || default_locale
  end

  # 2 of 2 places untrusted user input can enter system
  def params_selected_locale
    filter_locales(params[:locale], all_locale_strings).first
  end

  def user_selected_locale
    first_selectable_locale current_user_or_visitor.selected_locale
  end

  def first_detectable_locale(locales)
    filter_locales(locales, detectable_locales).first
  end

  def first_selectable_locale(locales)
    filter_locales(locales, selectable_locales).first
  end

  def filter_locales(input_locales, valid_locales)
    input_locales = Array(input_locales).map &:to_s
    valid_locales = Array(valid_locales).map &:to_s

    ( input_locales & valid_locales ).map(&:to_sym)
  end
end
