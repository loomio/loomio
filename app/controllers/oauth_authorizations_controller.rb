class OauthAuthorizationsController < Doorkeeper::AuthorizationsController

  helper_method :dashboard_or_root_path

  protected

  def dashboard_or_root_path
    if user_signed_in?
      dashboard_path
    else
      root_path
    end
  end
end
