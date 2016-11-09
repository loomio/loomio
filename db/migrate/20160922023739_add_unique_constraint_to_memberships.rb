class AddUniqueConstraintToMemberships < ActiveRecord::Migration
  def change
    execute "DELETE FROM memberships m1 USING memberships m2 
  WHERE m1.user_id = m2.user_id AND m1.group_id = m2.group_id AND
    m1.id < m2.id"
    add_index :memberships, [:group_id, :user_id], unique: true
  end
end
