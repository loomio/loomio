require 'http_accept_language'

module LocalesHelper
  LANGUAGES = {'English' => :en,
               'български' => :bg,
               'Català' => :ca,
               'čeština' => :cs,
               '正體中文' => :zh, #zh-Hant, Chinese (traditional), Taiwan
               'Deutsch' => :de,
               'Español' => :es,
               'ελληνικά' => :el,
               'Français' => :fr,
               'Indonesian' => :id,
               'magyar' => :hu,
               '日本語' => :ja,
               '한국어' => :ko,
               'മലയാളം' => :ml,
               'Nederlands' => :nl,
               'Português (Brasil)' => :pt,
               'română' => :ro,
               'srpski' => :sr,
               'Svenska' => :sv,
               'Tiếng Việt' => :vi,
               'Türkçe' => :tr,
               'українська мова' => :uk}

  EXPERIMENTAL_LANGUAGES = {'Chinese (Mandarin)' => :cmn,
                            'Italiano' => :it,
                            'తెలుగు' => :te,
                            'Gaelic (Irish)' => :ga,
                            'Esperanto' => :eo,
                            'Telugu' => :te,
                            'khmer' => :km}

  def locale_name(locale)
    LANGUAGES.key(locale.to_s)
  end

  def supported_locales
    LANGUAGES.values
  end

  def experimental_locales
    EXPERIMENTAL_LANGUAGES.values
  end

  def valid_locale?(locale)
    return false if locale.blank?
    (LANGUAGES.values + EXPERIMENTAL_LANGUAGES.values).include? locale.to_s
  end

  def language_link_attributes(language)
    { href: "?&locale=#{language[1]}"  ,
      title: "#{I18n.t(:change_language, language: language[0])}",
      text: "#{language[0]}" }
  end

  def selected_locale
    (params[:locale] || current_user_or_visitor.selected_locale).try(:to_s)
  end

  def locale_selected?
    params.has_key?(:locale) || current_user_or_visitor.locale.present?
  end

  def detected_locale
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
end
