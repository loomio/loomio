class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token
  include OmniauthAuthenticationHelper

  def all
    auth_params = ActionController::Parameters.new(request.env["omniauth.auth"])
    user_info = auth_params.require(:info).permit(
      :name,
      :email,
      :nickname,
      :location,
      :image,
      :description,
      :first_name,
      :last_name,
      :verified,
      urls: [:GitHub, :Blog, :Website, :Twitter, :Facebook, :Google])
    auth = OmniauthIdentity.from_omniauth(auth_params[:provider], auth_params[:uid], user_info)

    if auth.user
      sign_in_and_redirect(auth.user)
    else
      save_omniauth_authentication_to_session(auth)

      if user = User.find_by_email(auth.email.to_s)
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
          redirect_to login_or_signup_path_for_email(auth.email)
        end
      # end block that could be removed
      else
        redirect_to login_or_signup_path_for_email(auth.email)
      end
    end
  end

  alias_method :google, :all
  alias_method :facebook, :all
  alias_method :twitter, :all
  alias_method :github, :all

  private
  def sign_in_and_redirect(user)
    flash[:notice] = t(:'devise.sessions.signed_in')
    sign_in(:user, user)
    redirect_to after_sign_in_path_for(user)
  end
end
