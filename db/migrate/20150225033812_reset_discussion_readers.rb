class ResetDiscussionReaders < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("UPDATE discussion_readers SET read_salient_items_count = (SELECT count(id) FROM events WHERE discussion_id = discussion_readers.discussion_id AND events.created_at <= discussion_readers.last_read_at AND events.kind IN ('new_comment', 'new_motion', 'new_vote', 'motion_outcome_created') )")
  end
end
