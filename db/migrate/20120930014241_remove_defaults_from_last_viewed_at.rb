class RemoveDefaultsFromLastViewedAt < ActiveRecord::Migration
  def up
    change_column_default(:memberships, :last_viewed_at, nil)
    change_column_default(:discussion_read_logs, :discussion_last_viewed_at, nil)
    Membership.update_all(:last_viewed_at => Time.now)
    DiscussionReadLog.update_all(:discussion_last_viewed_at => Time.now)
  end

  def down
    change_column_default(:memberships, :last_viewed_at, Time.now)
    change_column_default(:discussion_read_logs, :discussion_last_viewed_at, Time.now)
  end
end
