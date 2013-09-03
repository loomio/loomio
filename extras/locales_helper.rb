module LocalesHelper
  def set_locale
    set_application_locale(best_available_locale)
  end

  def set_application_locale(locale)
    locale = I18n.default_locale if locale.blank?
    I18n.locale = locale
  end

  def best_available_locale
    if locale_given_in_params?
      locale = parse_locale_from_params
      update_user_locale_preference(locale)
      locale
    else
      if user_locale_preference_exists?
        current_user.language_preference
      else
        locale = parse_locale_from_request_header
        update_user_locale_preference(locale)
        locale
      end
    end
  end

  def locale_given_in_params?
    params[:locale].present?
  end

  def parse_locale_from_params
    params[:locale] if (valid_locale?(params[:locale]) || experimental_locale?(params[:locale]))
  end

  def update_user_locale_preference(locale)
    current_user.update_attribute(:language_preference, locale) if current_user
  end

  def user_locale_preference_exists?
    current_user && current_user.language_preference.present?
  end

  def parse_locale_from_request_header
    locale = request.env['HTTP_ACCEPT_LANGUAGE'].try(:scan, /^[a-z]{2}/).try(:first).try(:to_s)
    if valid_locale? locale
      locale
    else
      nil
    end
  end

  def valid_locale?(locale)
    Translation.locales.include? locale
  end

  def experimental_locale?(locale)
    Translation.experimental_locales.include? locale
  end

  def best_locale(preference, fallback)
    if preference.present?
      preference
    elsif fallback.present?
      fallback
    elsif preference.blank? && fallback.blank?
      I18n.default_locale
    end
  end
end
