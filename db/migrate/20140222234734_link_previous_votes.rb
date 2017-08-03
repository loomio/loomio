class LinkPreviousVotes < ActiveRecord::Migration
  class Vote < ActiveRecord::Base
  end


  def up
    puts "Linking votes to previous votes"

    Vote.find_each do |vote|
      if previous_vote = Vote.where(motion_id: vote.motion_id, user_id: vote.user_id, age: vote.age + 1).first
        vote.update_attribute(:previous_vote_id, previous_vote.id)
      end
    end
  end

  def down
  end
end
