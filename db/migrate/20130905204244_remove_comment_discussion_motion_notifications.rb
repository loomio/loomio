class RemoveCommentDiscussionMotionNotifications < ActiveRecord::Migration
  def up
    count = 0
    Event.where(kind: ['new_motion', 'new_comment', 'new_discussion']).find_each do |event|
      event.notifications.delete_all
      count += 1
      puts count if (count % 100) == 0
    end
  end

  def down
  end
end
