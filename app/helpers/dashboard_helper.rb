module DashboardHelper

  private

  def dashboard_events
    LatestEventsQuery.latest_events_for(user: current_user, discussion_ids: dashboard_threads.pluck(:id))
  end

  def dashboard_threads
    GroupDiscussionsViewer.for(user: current_user, group: @group, filter: params[:filter])
                          .not_muted
                          .where('last_activity_at > ?', 3.months.ago)
                          .joined_to_current_motion
                          .preload(:current_motion, {group: :parent})
                          .order('motions.closing_at ASC, last_activity_at DESC')
  end

  def grouped(discussions)
    discussions.map { |g, discussions| discussions.first(Integer(params[:per] || 5)) }.flatten
  end

end
