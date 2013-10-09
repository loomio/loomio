class Users::SessionsController < Devise::SessionsController
  layout 'pages'
  include AutodetectTimeZone
  include InvitationsHelper
  include OmniauthAuthenticationHelper
  before_filter :load_invitation_from_session, only: :new
  after_filter :set_time_zone_from_javascript, only: :create
end
