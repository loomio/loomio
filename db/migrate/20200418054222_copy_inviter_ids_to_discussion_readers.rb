class CopyInviterIdsToDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    execute "UPDATE discussion_readers
             SET inviter_id = memberships.inviter_id,
                 token = memberships.token
             FROM discussions, memberships
             WHERE discussion_readers.discussion_id = discussions.id AND
                   memberships.group_id = discussions.guest_group_id"

    execute "DELETE FROM memberships WHERE user_id IS NULL"
    execute "VACUUM FULL memberships"

    execute "CREATE TEMP TABLE membership_event_ids (id INT)"
    execute "INSERT INTO membership_event_ids (id) select events.id from events LEFT OUTER JOIN memberships ON events.eventable_id = memberships.id where eventable_type='Membership' and memberships.id is null"
    execute "DELETE FROM events where id in (SELECT id from membership_event_ids)"

    execute "CREATE TEMP TABLE notification_ids (id INT)"
    execute "INSERT INTO notification_ids (id) SELECT notifications.id FROM notifications LEFT OUTER JOIN events on notifications.event_id = events.id WHERE events.id is null"
    execute "DELETE FROM notifications WHERE id IN (select id from notification_ids)"
  end
end
