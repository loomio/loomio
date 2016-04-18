class AngularController < ApplicationController
  before_filter :authenticate_user!
  layout 'pages'

  def index
    @mode = if current_user.angular_ui_enabled?
             'disable'
           else
             'enable'
           end
    @enabled = current_user_or_visitor.angular_ui_enabled?
  end

  def on
    current_user.update_attribute :angular_ui_enabled, true
    redirect_to dashboard_path(welcome: true)
  end

  def off
    current_user.update_attribute :angular_ui_enabled, false
    redirect_to '/'
  end
end
