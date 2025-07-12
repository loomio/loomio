module Dev::Scenarios::Dashboard
  include Dev::DashboardHelper

  def setup_dashboard
    sign_in patrick
    pinned_discussion
    poll_discussion
    recent_discussion
    redirect_to dashboard_path
  end

  def setup_dashboard_with_one_thread
    create_another_group
    sign_in patrick
    recent_discussion
    redirect_to dashboard_path
  end

  def setup_dashboard_as_visitor
    patrick; jennifer
    recent_discussion
    redirect_to dashboard_path
  end
end
