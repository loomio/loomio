class Users::SessionsController < Devise::SessionsController
  include AutodetectTimeZone
  after_filter :set_time_zone_from_javascript, only: [:create]
  layout 'pages'
end
