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
    execute "DELETE FROM events
             USING events e
             LEFT OUTER JOIN memberships m ON e.eventable_type = 'Membership' and e.eventable_id = m.id
             WHERE m.id IS NULL"
  end
end
