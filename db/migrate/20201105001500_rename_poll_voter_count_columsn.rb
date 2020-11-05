class RenamePollVoterCountColumsn < ActiveRecord::Migration[5.2]
  def change
    rename_column :polls, :stances_count, :voters_count
    rename_column :polls, :undecided_count, :undecided_voters_count
  end
end
