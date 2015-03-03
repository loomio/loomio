class AngularController < ApplicationController
  before_filter :authenticate_user!

  def index
    @enabled = current_user_or_visitor.angular_ui_enabled?
    render 'index', layout: false
  end

  def on
    current_user.update_attribute :angular_ui_enabled, true
    redirect_to '/'
  end

  def off
    current_user.update_attribute :angular_ui_enabled, false
    redirect_to '/'
  end
end
