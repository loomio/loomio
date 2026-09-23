class WidenPollOptionTotalScore < ActiveRecord::Migration[8.1]
  def change
    change_column :poll_options, :total_score, :bigint, default: 0, null: false
  end
end
