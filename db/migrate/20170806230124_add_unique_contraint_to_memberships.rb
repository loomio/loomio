class AddUniqueContraintToMemberships < ActiveRecord::Migration
  def change
    execute "DELETE FROM memberships WHERE id IN (SELECT id FROM (SELECT id, ROW_NUMBER() OVER (partition BY group_id, user_id ORDER BY id) AS rnum FROM memberships) t WHERE t.rnum > 1);"
    add_index :memberships, [:group_id, :user_id], unique: true
  end
end
