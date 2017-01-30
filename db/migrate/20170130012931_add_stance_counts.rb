class AddStanceCounts < ActiveRecord::Migration
  def change
    add_column :polls, :stance_counts, :jsonb, null: false, default: []
  end
end
