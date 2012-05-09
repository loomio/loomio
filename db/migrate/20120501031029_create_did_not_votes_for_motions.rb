class CreateDidNotVotesForMotions < ActiveRecord::Migration
  def up
    Motion.all.each do |motion|
      motion.group.users.each do |user|
        unless motion.user_has_voted?(user)
          DidNotVote.create(user: user, motion: motion)
        end
      end
    end
  end

  def down
    DidNotVote.delete_all
  end
end
