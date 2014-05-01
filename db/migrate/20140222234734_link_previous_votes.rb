class LinkPreviousVotes < ActiveRecord::Migration
  class Vote < ActiveRecord::Base
  end


  def up
    puts "Linking votes to previous votes"
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Vote.count )

    Vote.find_each do |vote|
      progress_bar.increment
      if previous_vote = Vote.where(motion_id: vote.motion_id, user_id: vote.user_id, age: vote.age + 1).first
        vote.update_attribute(:previous_vote_id, previous_vote.id)
      end
    end
  end

  def down
  end
end
