class AddHasMutedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_muted, :boolean, null: false, default: false
  end
end
