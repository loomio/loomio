class Users::SessionsController < Devise::SessionsController
  layout 'pages'
  include AutodetectTimeZone
  include InvitationsHelper
  include OmniauthAuthenticationHelper

  # at some point in the future we can remove this
  before_filter :create_parse_user_if_needed, only: :create

  before_filter :store_previous_location, only: :new
  before_filter :load_invitation_from_session, only: :new
  after_filter :set_time_zone_from_javascript, only: :create

  def new
    super { |user| user.email = params[:email] }
  end

  private

  # and this
  def create_parse_user_if_needed
    if ENV['PARSE_ID'] and request.subdomain == ENV['PARSE_SUBDOMAIN']
      unless warden.authenticate?(auth_options)
        if user_hash = ParseAuth.login_with_email_and_password(params[:user][:email], params[:user][:password])

          unless u = User.find_by_email(params[:user][:email])
            u = User.create!(name: "#{user_hash['firstname']} #{user_hash['lastname']}",
                             email: params[:user][:email],
                             password: params[:user][:password])
          end

          g = Group.find(ENV['PARSE_GROUP_ID'])
          g.add_member!(u)
          flash[:notice] = t(:'devise.sessions.signed_in')
          sign_in(:user, u)
          redirect_to after_sign_in_path_for(u)
        end
      end
    end
  end
end
