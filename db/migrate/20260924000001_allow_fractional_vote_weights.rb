class AllowFractionalVoteWeights < ActiveRecord::Migration[8.1]
  def change
    change_column :memberships, :weight, :decimal, precision: 12, scale: 3, default: 1, null: false
    change_column :stances, :weight, :decimal, precision: 12, scale: 3, default: 1, null: false
    change_column :poll_options, :total_score, :decimal, precision: 30, scale: 3, default: 0, null: false
    reversible do |direction|
      direction.up do
        execute <<~SQL
          UPDATE stances SET weight = 1
          FROM polls
          WHERE stances.poll_id = polls.id AND polls.vote_weights_enabled = FALSE
        SQL
      end
    end
  end
end
