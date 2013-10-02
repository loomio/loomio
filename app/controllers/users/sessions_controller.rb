class Users::SessionsController < Devise::SessionsController
  layout 'pages'
  include AutodetectTimeZone
  after_filter :set_time_zone_from_javascript, only: [:create]
  helper :omniauth_authentication
end
