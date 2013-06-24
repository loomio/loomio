class AddVoteCountsToMotions < ActiveRecord::Migration

  class Motion < ActiveRecord::Base
    has_many :votes, :dependent => :destroy

    def update_vote_counts!
      %w[yes abstain no block].each do |position|
        count = votes.where(position: position).count
        self.update_attribute("#{position}_votes_count", count)
      end
    end
  end

  def up
    add_column :motions, :yes_votes_count, :integer, null: false, default: 0
    add_column :motions, :no_votes_count, :integer, null: false, default: 0
    add_column :motions, :abstain_votes_count, :integer, null: false, default: 0
    add_column :motions, :block_votes_count, :integer, null: false, default: 0
    Motion.reset_column_information
    Motion.find_each do |m|
      m.update_vote_counts!
    end
  end

  def down
    remove_column :motions, :yes_votes_count
    remove_column :motions, :no_votes_count
    remove_column :motions, :abstain_votes_count
    remove_column :motions, :block_votes_count
  end
end
