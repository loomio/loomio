class EliminateOrphanVotes < ActiveRecord::Migration
  def up
    destroyed_votes = []
    Vote.includes(:motion).find_each(batch_size: 100) do |vote|
      if vote.motion.nil?
        destroyed_votes << vote.id
        vote.destroy
      end
    end
    puts "Destroyed the following votes: #{destroyed_votes}"
  end

  def down
  end
end
