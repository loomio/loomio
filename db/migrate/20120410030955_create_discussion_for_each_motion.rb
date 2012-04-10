class CreateDiscussionForEachMotion < ActiveRecord::Migration
  def up
    Motion.all.each do |motion|
      if motion.discussion_id == nil
        motion.discussion = Discussion.create(author_id: motion.author.id, group_id: motion.group.id)
        motion.save
      end
    end
  end

  def down
  end
end
