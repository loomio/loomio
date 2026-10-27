class RenamePollParticipationColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :polls, :voters_count, :vote_count_total
    rename_column :polls, :undecided_voters_count, :vote_count_uncast
    rename_column :polls, :none_of_the_above_count, :vote_count_none_of_the_above
    rename_column :polls, :stance_counts, :scores_by_option
  end
end
