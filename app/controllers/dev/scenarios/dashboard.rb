module Dev::Scenarios::Dashboard
  include Dev::DashboardHelper

  def setup_dashboard
    ENV['FEATURES_GROUP_SURVEY'] = params[:features_group_survey]
    sign_in patrick
    pinned_discussion
    poll_discussion
    recent_discussion
    redirect_to dashboard_url
  end

  def setup_dashboard_with_one_thread
    sign_in patrick
    recent_discussion
    redirect_to dashboard_url
  end

  def setup_dashboard_as_visitor
    patrick; jennifer
    recent_discussion
    redirect_to dashboard_url
  end
end
