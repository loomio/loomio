class API::LoginTokensController < API::RestfulController
  before_action :update_detected_locale, only: :create
  
  def create
    service.create(actor: login_token_user, uri: URI::parse(request.referrer.to_s))
    head :ok
  end

  private
  def update_detected_locale
    if locales_from_browser_detection.any?
      login_token_user.update_detected_locale(locales_from_browser_detection.first)
    end
  end

  def login_token_user
    User.verified_first.find_by!(email: params.require(:email))
  end
end
