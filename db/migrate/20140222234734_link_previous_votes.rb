class LinkPreviousVotes < ActiveRecord::Migration
  class Vote < ActiveRecord::Base
    belongs_to :motion
    belongs_to :previous_vote, class_name: 'Vote'

    def associate_previous_vote
      self.previous_vote = motion.votes.where(user_id: user_id, age: age + 1).first
    end
  end


  def up
    puts "Linking votes to previous votes"
    progress_bar = ProgressBar.create( format: "(\e[32m%c/%C\e[0m) %a |%B| \e[31m%e\e[0m ", progress_mark: "\e[32m/\e[0m", total: Vote.count )

    Vote.find_each do |vote|
      progress_bar.increment
      vote.associate_previous_vote
      vote.save!
    end
  end

  def down
  end
end
