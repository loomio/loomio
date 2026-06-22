class AddRedactedAtToStances < ActiveRecord::Migration[8.0]
  def change
    add_column :stances, :redacted_at, :datetime
  end
end
