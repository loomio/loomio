class RemovePollVotingSystem < ActiveRecord::Migration[8.1]
  # Every anonymous poll uses anonymous ballots, so voting_system only repeated
  # the anonymous flag; the check constraint kept the two identical.
  def up
    remove_check_constraint :polls, name: "polls_anonymous_voting_system"
    remove_column :polls, :voting_system
  end

  def down
    add_column :polls, :voting_system, :integer, default: 0, null: false
    execute "UPDATE polls SET voting_system = 1 WHERE anonymous"
    add_check_constraint :polls,
      "anonymous = true AND voting_system = 1 OR anonymous = false AND voting_system = 0",
      name: "polls_anonymous_voting_system"
  end
end
