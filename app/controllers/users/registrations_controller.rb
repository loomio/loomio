class Users::RegistrationsController < Devise::RegistrationsController
  include AutodetectTimeZone
  layout 'pages'
  after_filter :set_time_zone_from_javascript, only: [:create]
end
