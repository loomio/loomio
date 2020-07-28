class DeleteDanglingMemberships < ActiveRecord::Migration[5.2]
  def up
    execute "create temp table memberships_to_delete (id int)"
    execute "insert into memberships_to_delete (id) select memberships.id from memberships left outer join users on memberships.user_id = users.id where users.id is null"
    execute "delete from memberships where id in (select id from memberships_to_delete)"
  end
end
