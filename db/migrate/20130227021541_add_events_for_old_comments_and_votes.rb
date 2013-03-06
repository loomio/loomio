class AddEventsForOldCommentsAndVotes < ActiveRecord::Migration
  def up
    Comment.find_each(batch_size: 100) do |comment|
      unless Event.where(eventable_id: comment.id, eventable_type: "Comment").exists?
        event = Event.new(kind: "new_comment",
                          eventable: comment,
                          discussion_id: comment.discussion.id)
        event.created_at = comment.created_at
        event.updated_at = comment.updated_at
        event.save!
      end
    end
    Vote.find_each(batch_size: 100) do |vote|
      unless Event.where(eventable_id: vote.id, eventable_type: "Vote").exists?
        kind = (vote.position == "block") ? "motion_blocked" : "new_vote"
        event = Event.new(kind: kind,
                          eventable: vote,
                          discussion_id: vote.discussion.id)
        event.created_at = vote.created_at
        event.updated_at = vote.updated_at
        event.save!
      end
    end
  end

  def down
  end
end
