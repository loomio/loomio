class AddUniqueConstraintToMemberships < ActiveRecord::Migration
  def change
    add_index :memberships, [:group_id, :user_id], unique: true
  end
end
