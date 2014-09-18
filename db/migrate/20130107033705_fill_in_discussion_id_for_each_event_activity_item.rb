class FillInDiscussionIdForEachEventActivityItem < ActiveRecord::Migration
  class Event < ActiveRecord::Base
    KINDS = %w[new_discussion discussion_title_edited discussion_description_edited new_comment
           new_motion new_vote motion_blocked motion_close_date_edited
           motion_closing_soon motion_closed membership_requested
           user_added_to_group comment_liked user_mentioned]
    belongs_to :eventable, :polymorphic => true
    belongs_to :user
    validates_inclusion_of :kind, :in => KINDS
    validates_presence_of :eventable
    #attr_accessible :kind, :eventable, :user, :discussion_id
  end

  def up
    Event.find_each(:batch_size => 100) do |event|
      case event.kind
        when 'new_comment'
          event.discussion_id = event.eventable.commentable_id
        when 'new_motion', 'motion_closed', 'motion_close_date_edited'
          event.discussion_id = event.eventable.discussion_id
        when 'new_vote', 'motion_blocked'
          event.discussion_id = event.eventable.motion.discussion_id
        when 'new_discussion', 'discussion_title_edited', 'discussion_description_edited'
          event.discussion_id = event.eventable_id
      end
      event.save(:validate => false)
    end
  end

  def down
    Event.update_all "discussion_id = Null"
  end
end
