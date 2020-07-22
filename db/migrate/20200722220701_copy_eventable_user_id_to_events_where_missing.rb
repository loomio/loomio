class CopyEventableUserIdToEventsWhereMissing < ActiveRecord::Migration[5.2]
  def up
    execute "CREATE TEMP TABLE event_users (event_id INT, user_id INT)"
    execute "INSERT INTO event_users (event_id, user_id)
                    SELECT e.id, c.user_id as user_id
                    FROM events e JOIN comments c ON e.eventable_id = c.id
                    WHERE e.eventable_type = 'Comment'
                    AND   e.user_id IS NULL AND c.id IS NOT NULL"

    # below is a complicated way of doing the following simpler update, which is too slow on loomio.org
    # execute "UPDATE events SET user_id = event_users.user_id FROM event_users WHERE event_users.event_id = events.id"
    n = 0
    i = 10000
    while (n < 8000000) do
      execute "UPDATE events SET user_id = event_users.user_id
                 FROM event_users
                 WHERE event_users.event_id = events.id
                   AND events.user_id IS NULL
                   AND event_users.user_id IS NOT NULL
                   AND events.id < #{n+i} and events.id >= #{n}"
      n = n + i
    end
  end
end
