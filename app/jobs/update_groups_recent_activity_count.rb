class UpdateGroupsRecentActivityCount < ActiveJob::Base
  def perform
    FormalGroup.published.find_each(&:update_recent_activity_count)
  end
end
