class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include OmniauthAuthenticationHelper
  include InvitationsHelper

  def all
    auth = OmniauthIdentity.from_omniauth(request.env["omniauth.auth"])

    if auth.user
      sign_in_and_redirect(auth.user)
    else
      save_omniauth_authentication_to_session(auth)

      if user = User.find_by_email(auth.email)
        sign_in_and_redirect(user)
      else
        redirect_to login_or_signup_path_for_email(auth.email)
      end
    end
  end

  alias_method :google, :all
  alias_method :facebook, :all
  alias_method :browser_id, :all

  private
  def sign_in_and_redirect(user)
    flash[:notice] = t(:'devise.sessions.signed_in')
    sign_in(:user, user)
    redirect_to after_sign_in_path_for(user)
  end
end
