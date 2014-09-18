class ConvertMotionBlockedToNewVote < ActiveRecord::Migration
  def change
    Event.where(kind: 'motion_blocked').update_all(kind: 'new_vote')
  end
end
