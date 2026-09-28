class AddWeightedTotalsToPollOptions < ActiveRecord::Migration[8.1]
  # Weighted results read these stored totals instead of summing stance choices
  # for every option each time a poll is serialized. Only weighted polls read
  # them, so only their options need backfilling.
  def up
    add_column :poll_options, :unweighted_score, :bigint, default: 0, null: false
    add_column :poll_options, :voter_weight_total, :decimal, precision: 30, scale: 3, default: 0, null: false

    execute <<~SQL.squish
      UPDATE poll_options
      SET unweighted_score = totals.unweighted_score,
          voter_weight_total = totals.voter_weight_total
      FROM (
        SELECT stance_choices.poll_option_id,
               SUM(stance_choices.score) AS unweighted_score,
               SUM(stances.weight) AS voter_weight_total
        FROM stance_choices
        JOIN stances ON stances.id = stance_choices.stance_id
        JOIN polls ON polls.id = stances.poll_id
        WHERE polls.vote_weights_enabled
          AND stances.latest
          AND stances.revoked_at IS NULL
        GROUP BY stance_choices.poll_option_id
      ) AS totals
      WHERE poll_options.id = totals.poll_option_id
    SQL
  end

  def down
    remove_column :poll_options, :voter_weight_total
    remove_column :poll_options, :unweighted_score
  end
end
