class AddVoterScoresToPollOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :poll_options, :voter_scores, :jsonb, default: {}, null: false
  end
end
