class Users::RegistrationsController < Devise::RegistrationsController
  layout 'pages'

  before_filter :redirect_if_robot, only: :create

  include AutodetectTimeZone
  after_filter :set_time_zone_from_javascript, only: [:create]

  include InvitationsHelper
  before_filter :load_invitation_from_session, only: :new

  include OmniauthAuthenticationHelper
  def new
    @user = User.new
    if @invitation
      if @invitation.intent == 'start_group'
        @user.name = @invitation.recipient_name
        @user.email = @invitation.recipient_email
      else
        @user.email = @invitation.recipient_email
      end
    end

    if omniauth_authenticated_and_waiting?
      load_omniauth_authentication_from_session
      @user.name = @omniauth_authentication.name
      @user.email = @omniauth_authentication.email
    end
  end

  private

  def redirect_if_robot
    if params[:user][:honeypot].present?
      flash[:warning] = t(:honeypot_warning)
      redirect_to new_user_registration_path
    else
      params[:user] = params[:user].except(:honeypot)
    end
  end
end
