class WallController < BaseController
  def show
    # discussions that had activity in the last 24 hours

    groups = current_user.inbox_groups
    @time_since = 2.day.ago
    @discussions = Queries::VisibleDiscussions.new(user: current_user,
                                                   groups: groups).
                                               unread.
                                               active_since(@time_since)

    @discussions_by_group = @discussions.group_by { |d| d.group }
    @user = current_user
    @utm_hash = {}
  end
end
