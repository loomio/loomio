class Users::RegistrationsController < Devise::RegistrationsController
  layout 'pages'
  include AutodetectTimeZone
  after_filter :set_time_zone_from_javascript, only: [:create]

  include InvitationsHelper
  before_filter :load_invitation_from_session, only: :new

  helper :persona
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
  end
end
