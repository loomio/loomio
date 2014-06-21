class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include OmniauthAuthenticationHelper
  include InvitationsHelper

  def all
    auth = OmniauthIdentity.from_omniauth(request.env["omniauth.auth"])

    if auth.user
      Measurement.increment('omniauth.success.recognised')
      sign_in_and_redirect(auth.user)
    else
      save_omniauth_authentication_to_session(auth)

      if user = User.find_by_email(auth.email.to_s)
        Measurement.increment('omniauth.success.recognised_first_auth')
        sign_in_and_redirect(user)

      # at some point in the future we can remove this elsif #IAMSORRY4THIS
      elsif ENV['PARSE_ID'] and request.subdomain == ENV['PARSE_SUBDOMAIN']
        if parse_user = ParseAuth.get_user_details(auth.email.to_s)
          user = User.create!(name: "#{parse_user['firstname']} #{parse_user['lastname']}",
                              email: auth.email.to_s,
                              password: SecureRandom.hex)

          group = Group.find(ENV['PARSE_GROUP_ID'])
          group.add_member!(user)
          sign_in_and_redirect(user)
        else
          Measurement.increment('omniauth.success.unrecognised_first_auth')
          redirect_to login_or_signup_path_for_email(auth.email)
        end
      # end block that could be removed
      else
        Measurement.increment('omniauth.success.unrecognised_first_auth')
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
