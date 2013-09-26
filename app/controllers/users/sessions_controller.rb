class Users::SessionsController < Devise::SessionsController
  layout 'pages'
  include AutodetectTimeZone
  after_filter :set_time_zone_from_javascript, only: [:create]

  include InvitationsHelper
  before_filter :load_invitation_from_session, only: :new
  before_filter :set_user_defaults_from_invitation, only: :new
  helper :persona
end
