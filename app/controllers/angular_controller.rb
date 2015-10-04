class AngularController < ApplicationController
  before_filter :authenticate_user!
  layout 'pages'

  def index
    @enabled = current_user_or_visitor.angular_ui_enabled?
    @feedback = FeedbackResponse.new
  end

  def on
    current_user.update_attribute :angular_ui_enabled, true
    redirect_to '/'
  end

  def off
    current_user.update_attribute :angular_ui_enabled, false
    FeedbackResponse.create(feedback_params)
    redirect_to '/'
  end

  private

  def feedback_params
    permitted_params.feedback_response.merge({
      user_id:  (current_user && current_user.id),
      visit_id: (current_visit && current_visit.id),
      version:  Loomio::Version.current
    })
  end
end
