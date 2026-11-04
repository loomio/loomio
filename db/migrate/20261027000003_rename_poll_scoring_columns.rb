class RenamePollScoringColumns < ActiveRecord::Migration[8.1]
  def change
    %i[polls poll_templates].each do |table|
      rename_column table, :min_score, :score_min
      rename_column table, :max_score, :score_max
      rename_column table, :minimum_stance_choices, :choice_count_min
      rename_column table, :maximum_stance_choices, :choice_count_max
      rename_column table, :dots_per_person, :points_per_voter
    end

    rename_column :poll_options, :voter_count, :vote_count
    rename_column :poll_options, :voter_scores, :scores_by_voter
    rename_column :poll_options, :voter_weight_total, :vote_weight
    rename_column :poll_options, :score_counts, :vote_counts_by_score
  end
end
