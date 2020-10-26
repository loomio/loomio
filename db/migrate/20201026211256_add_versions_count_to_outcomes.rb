class AddVersionsCountToOutcomes < ActiveRecord::Migration[5.2]
  def change
    add_column :outcomes, :versions_count, :integer, default: 0, null: false
  end
end
