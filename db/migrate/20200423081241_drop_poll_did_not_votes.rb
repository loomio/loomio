class DropPollDidNotVotes < ActiveRecord::Migration[5.2]
  def change
    drop_table :poll_did_not_votes
  end
end
