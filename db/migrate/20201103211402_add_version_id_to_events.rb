class AddVersionIdToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :eventable_version_id, :integer, null: true, default: nil
  end
end
