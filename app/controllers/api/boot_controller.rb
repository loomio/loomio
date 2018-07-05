class API::BootController < API::RestfulController
  def site
    render json: Boot::Site.new.payload(detected_locale: detected_locale)
  end

  def user
    render json: Boot::User.new(current_user, identity: serialized_pending_identity, flash: flash).payload
  end

  private
  def detected_locale
    first_supported_locale(browser_detected_locales)
  end
end
