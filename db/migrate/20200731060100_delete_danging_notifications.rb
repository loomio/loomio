class DeleteDangingNotifications < ActiveRecord::Migration[5.2]
  def change
    execute "create temp table dnots (id INT)"
    execute "insert into dnots (id) select notifications.id from notifications left outer join events on notifications.event_id = events.id where events.id is null"
    execute "delete from notifications where id in (select id from dnots)"
  end
end
