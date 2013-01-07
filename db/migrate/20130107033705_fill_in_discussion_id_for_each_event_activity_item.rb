class FillInDiscussionIdForEachEventActivityItem < ActiveRecord::Migration
  class Event < ActiveRecord::Base
  end

  def up
    Event.all.each do |event|
      case event.kind
        when 'new_comment'
          event.discussion_id = event.eventable.discussion.id
        when 'new_motion', 'motion_closed', 'motion_close_date_edited'
          event.discussion_id = event.eventable.discussion.id
        when 'new_vote', 'motion_blocked'
          event.discussion_id = event.eventable.motion.discussion.id
        when 'new_discussion', 'discussion_title_edited', 'discussion_description_edited'
          event.discussion_id = event.eventable.id
      end
      event.save
    end
  end

  def down
    Event.update_all "discussion_id = Null"
  end
end
