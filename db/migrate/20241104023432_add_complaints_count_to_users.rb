class AddComplaintsCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :complaints_count, :integer, default: 0, null: false
  end
end
