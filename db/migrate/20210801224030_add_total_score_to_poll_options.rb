class AddTotalScoreToPollOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :poll_options, :total_score, :integer, null: false, default: 0
  end
end
