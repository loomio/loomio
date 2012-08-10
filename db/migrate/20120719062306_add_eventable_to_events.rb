class AddEventableToEvents < ActiveRecord::Migration
  def up
    add_column :events, :eventable_id, :integer
    add_column :events, :eventable_type, :string

    Event.reset_column_information
    Event.all.each do |event|
      begin
        if event.discussion_id
          event.eventable = Discussion.find event.discussion_id
        elsif event.comment_id
          event.eventable = Comment.find event.comment_id
        elsif event.motion_id
          event.eventable = Motion.find event.motion_id
        elsif event.vote_id
          event.eventable = Vote.find event.vote_id
        elsif event.membership_id
          event.eventable = Membership.find event.membership_id
        elsif event.comment_vote_id
          event.eventable = CommentVote.find event.comment_vote_id
        end
        event.save
      rescue ActiveRecord::RecordNotFound
        event.destroy
      end
    end

    remove_column :events, :discussion_id
    remove_column :events, :comment_id
    remove_column :events, :motion_id
    remove_column :events, :vote_id
    remove_column :events, :membership_id
    remove_column :events, :comment_vote_id
  end

  def down
    add_column :events, :discussion_id, :integer
    add_column :events, :comment_id, :integer
    add_column :events, :motion_id, :integer
    add_column :events, :vote_id, :integer
    add_column :events, :membership_id, :integer
    add_column :events, :comment_vote_id, :integer

    Event.reset_column_information
    Event.all.each do |event|
      if event.eventable_type == "Discussion"
        event.discussion_id = event.eventable
      elsif event.eventable_type == "Comment"
        event.comment_id = event.eventable
      elsif event.eventable_type == "Motion"
        event.motion_id = event.eventable
      elsif event.eventable_type == "Vote"
        event.vote_id = event.eventable
      elsif event.eventable_type == "Membership"
        event.membership_id = event.eventable
      elsif event.eventable_type == "CommentVote"
        event.comment_vote_id = event.eventable
      end
      event.save
    end

    remove_column :events, :eventable_id, :integer
    remove_column :events, :eventable_type, :string
  end
end
