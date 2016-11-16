class CountGroupRecentActivityJob < ActiveJob::Base
  queue_as :low_priority

  def query
    "UPDATE groups SET
     recent_activity_count =
      (5* (SELECT count(discussions.id)
           FROM discussions
           WHERE discussions.group_id = groups.id
           AND discussions.created_at > current_date - 30)) +
      (5 * (SELECT count(motions.id)
           FROM motions
           JOIN discussions ON motions.discussion_id = discussions.id
           WHERE discussions.group_id = groups.id
           AND motions.created_at > current_date - 30))+
      (SELECT count(comments.id)
       FROM comments
       JOIN discussions ON comments.discussion_id = discussions.id
       WHERE discussions.group_id = groups.id
       AND comments.created_at > current_date - 30)"
  end

  def perform
    ActiveRecord::Base.connection.execute(query)
  end
end
