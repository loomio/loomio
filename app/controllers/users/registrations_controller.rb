class Users::RegistrationsController < Devise::RegistrationsController
  include AutodetectTimeZone
  layout 'pages'
  after_filter :set_time_zone_from_javascript, only: [:create]

  #in devise 3 this will change to sign_up_params
  def resource_params
    PermittedParams.new(params, current_user).user
  end
end
