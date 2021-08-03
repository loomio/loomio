class AddOptionScoresToStances < ActiveRecord::Migration[6.0]
  def change
    add_column :stances, :option_scores, :jsonb, default: {}, null: false
  end
end
