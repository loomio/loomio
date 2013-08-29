class AddDidNotVotesCountToMotions < ActiveRecord::Migration
  class Motion < ActiveRecord::Base
    has_many :did_not_votes
  end

  def up
    add_column :motions, :did_not_votes_count, :integer
    Motion.reset_column_information
    Motion.find_each do |motion|
      motion.update_attribute(:did_not_votes_count, motion.did_not_votes.count)
    end
  end

  def down
    remove_column :motions, :did_not_votes_count
  end
end
