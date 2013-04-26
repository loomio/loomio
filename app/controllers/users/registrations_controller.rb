class Users::RegistrationsController < Devise::RegistrationsController
  include AutodetectTimeZone
  layout 'frontpage'
  after_filter :set_time_zone_from_javascript, only: [:create]
end
