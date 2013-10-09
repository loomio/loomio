class Users::RegistrationsController < Devise::RegistrationsController
  layout 'pages'
  include AutodetectTimeZone
  after_filter :set_time_zone_from_javascript, only: [:create]

  include InvitationsHelper
  before_filter :load_invitation_from_session, only: :new

  include OmniauthAuthenticationHelper
  def new
    @user = User.new
    if @invitation
      if @invitation.intent == 'join_group'
        @user.email = @invitation.recipient_email
      else
        @user.name = @invitation.group_request_admin_name
        @user.email = @invitation.recipient_email
      end
    end

    if omniauth_authenticated_and_waiting?
      load_omniauth_authentication_from_session
      @user.name = @omniauth_authentication.name
      @user.email = @omniauth_authentication.email
    end
  end
end
