class AddEventsForOldLikes < ActiveRecord::Migration
  def up
    likes_that_have_been_fixed = []
    CommentVote.find_each(batch_size: 100) do |like|
      unless Event.where(eventable_id: like.id, eventable_type: "CommentVote").exists?
        event = Event.new(kind: "comment_liked",
                          eventable: like)
        event.created_at = like.created_at
        event.updated_at = like.updated_at
        event.save!
        likes_that_have_been_fixed << like
      end
    end
    puts "Timestamps for likes that have been fixed:"
    puts likes_that_have_been_fixed.map{|l| l.created_at.strftime("%Y %b %e")}.uniq
  end

  def down
  end
end
