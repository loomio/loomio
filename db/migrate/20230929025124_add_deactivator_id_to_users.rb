class AddDeactivatorIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :deactivator_id, :integer
  end
end
