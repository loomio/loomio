class AddVersionsCountToStances < ActiveRecord::Migration[5.1]
  def change
    add_column :stances, :versions_count, :integer, default: 0
  end
end
