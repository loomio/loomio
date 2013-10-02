class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include OmniauthAuthenticationHelper
  include InvitationsHelper

  def all
    auth = OmniauthIdentity.from_omniauth(request.env["omniauth.auth"])

    if auth.user
      flash[:notice] = t(:signed_in)
      sign_in(:user, auth.user)
      redirect_to after_sign_in_path_for(auth.user)
    else
      save_omniauth_authentication_to_session(auth)
      redirect_to login_or_signup_path_for_email(auth.email)
    end
  end

  alias_method :google, :all
  alias_method :facebook, :all
  alias_method :browser_id, :all
end
